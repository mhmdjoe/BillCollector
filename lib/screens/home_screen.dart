import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/bill.dart';
import '../screens/welcome_screen.dart';
import '../widgets/add_edit_bill_sheet.dart';
import '../widgets/bill_card.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/summary_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  late DateTime _selectedMonth;
  bool _showWelcomeScreen = true; // Show welcome page on initial launch

  AppSettings _settings = AppSettings(
    languageCode: 'en',
    currency: AppCurrency.usd,
  );

  bool _isDailyView = false; // Toggle between Daily vs Monthly Calculation
  String _filterType = 'All'; // 'All', 'Pending', 'Paid', 'Overdue'
  String _searchQuery = '';
  bool _isSearching = false;

  final List<Bill> _allBills = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Settings
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      try {
        setState(() {
          _settings = AppSettings.fromJson(jsonDecode(settingsJson));
          _showWelcomeScreen = false; // already launched before
        });
      } catch (e) {
        debugPrint('Error loading settings: $e');
      }
    }

    // Load Bills
    final billsJson = prefs.getStringList('all_bills');
    if (billsJson != null) {
      try {
        _allBills.clear();
        for (final str in billsJson) {
          _allBills.add(Bill.fromJson(jsonDecode(str)));
        }
      } catch (e) {
        debugPrint('Error loading bills: $e');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveBillsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final billsJson = _allBills.map((b) => jsonEncode(b.toJson())).toList();
    await prefs.setStringList('all_bills', billsJson);
  }

  Future<void> _saveSettingsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', jsonEncode(_settings.toJson()));
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
        1,
      );
    });
  }

  List<Bill> get _currentMonthBills {
    return _allBills.where((b) {
      return b.dueDate.year == _selectedMonth.year &&
          b.dueDate.month == _selectedMonth.month;
    }).toList();
  }

  List<Bill> get _currentDailyBills {
    final now = DateTime.now();
    return _currentMonthBills.where((b) {
      return b.dueDate.year == now.year &&
          b.dueDate.month == now.month &&
          b.dueDate.day == now.day;
    }).toList();
  }

  List<Bill> get _activeCalculationBills {
    return _isDailyView ? _currentDailyBills : _currentMonthBills;
  }

  List<Bill> get _filteredBills {
    return _activeCalculationBills.where((b) {
      if (_filterType == 'Paid' && !b.isPaid) return false;
      if (_filterType == 'Pending' && b.isPaid) return false;
      if (_filterType == 'Overdue' && b.status != BillStatus.overdue) return false;

      if (_searchQuery.isNotEmpty &&
          !b.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();
  }

  void _saveBill(Bill bill) {
    setState(() {
      final index = _allBills.indexWhere((b) => b.id == bill.id);
      if (index >= 0) {
        _allBills[index] = bill;
      } else {
        _allBills.add(bill);
      }
    });
    _saveBillsToStorage();
  }

  void _deleteBill(Bill bill) {
    final isArabic = _settings.isArabic;
    setState(() {
      _allBills.removeWhere((b) => b.id == bill.id);
    });
    _saveBillsToStorage();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${isArabic ? "تم حذف" : "Deleted"} "${bill.title}"'),
        action: SnackBarAction(
          label: isArabic ? 'تراجع' : 'Undo',
          onPressed: () {
            setState(() {
              _allBills.add(bill);
            });
            _saveBillsToStorage();
          },
        ),
      ),
    );
  }

  void _togglePaid(Bill bill, bool isPaid) {
    setState(() {
      final index = _allBills.indexWhere((b) => b.id == bill.id);
      if (index >= 0) {
        _allBills[index] = bill.copyWith(isPaid: isPaid);
      }
    });
    _saveBillsToStorage();
  }

  void _copyPreviousMonthRecurring() {
    final isArabic = _settings.isArabic;
    final prevMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
      1,
    );

    final prevBills = _allBills.where((b) {
      return b.dueDate.year == prevMonth.year &&
          b.dueDate.month == prevMonth.month &&
          b.isRecurring;
    }).toList();

    if (prevBills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic
              ? 'لا توجد فواتير متكررة من الشهر السابق.'
              : 'No recurring bills found from previous month.'),
        ),
      );
      return;
    }

    int count = 0;
    setState(() {
      for (final old in prevBills) {
        final exists = _currentMonthBills.any(
            (b) => b.title.toLowerCase() == old.title.toLowerCase());
        if (!exists) {
          _allBills.add(
            Bill(
              id: DateTime.now().microsecondsSinceEpoch.toString() + count.toString(),
              title: old.title,
              amount: old.amount,
              dueDate: DateTime(
                _selectedMonth.year,
                _selectedMonth.month,
                old.dueDate.day.clamp(1, 28),
              ),
              category: old.category,
              isPaid: false,
              isRecurring: true,
              notes: old.notes,
              imagePath: old.imagePath,
            ),
          );
          count++;
        }
      }
    });

    _saveBillsToStorage();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isArabic
            ? 'تم استيراد $count فواتير متكررة لهذا الشهر!'
            : 'Imported $count recurring bills for this month!'),
      ),
    );
  }

  void _openBillSheet([Bill? bill]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddEditBillSheet(
          initialBill: bill,
          initialMonth: _selectedMonth,
          onSave: _saveBill,
          settings: _settings,
        );
      },
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SettingsSheet(
          settings: _settings,
          onSettingsChanged: (newSettings) {
            setState(() {
              _settings = newSettings;
            });
            _saveSettingsToStorage();
          },
        );
      },
    );
  }

  void _pickMonth() async {
    final year = _selectedMonth.year;
    final isArabic = _settings.isArabic;

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: _settings.textDirection,
          child: AlertDialog(
            title: Text(isArabic ? 'اختر الشهر' : 'Select Month'),
            content: SizedBox(
              width: 280,
              height: 220,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, idx) {
                  final m = idx + 1;
                  const monthNamesEn = [
                    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                  ];
                  const monthNamesAr = [
                    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
                  ];

                  final monthName = isArabic ? monthNamesAr[idx] : monthNamesEn[idx];
                  final isSelected = _selectedMonth.month == m;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMonth = DateTime(year, m, 1);
                      });
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        monthName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _monthLabel(DateTime dt) {
    final isArabic = _settings.isArabic;
    const monthsEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const monthsAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];

    final mName = isArabic ? monthsAr[dt.month - 1] : monthsEn[dt.month - 1];
    return '$mName ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showWelcomeScreen) {
      return WelcomeScreen(
        settings: _settings,
        onSettingsChanged: (newSettings) {
          setState(() {
            _settings = newSettings;
          });
          _saveSettingsToStorage();
        },
        onGetStarted: () {
          setState(() {
            _showWelcomeScreen = false;
          });
          _saveSettingsToStorage();
        },
      );
    }

    final theme = Theme.of(context);
    final isArabic = _settings.isArabic;

    final calculationBills = _activeCalculationBills;
    final double totalAmount = calculationBills.fold(0.0, (s, b) => s + b.amount);
    final double paidAmount = calculationBills
        .where((b) => b.isPaid)
        .fold(0.0, (s, b) => s + b.amount);

    final int paidCount = calculationBills.where((b) => b.isPaid).length;
    final displayedBills = _filteredBills;

    final appTitleText = isArabic ? 'جامع الفواتير' : 'Bill Collector';

    return Directionality(
      textDirection: _settings.textDirection,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: _isSearching
              ? TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: isArabic ? 'بحث الفواتير...' : 'Search bills...',
                    border: InputBorder.none,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                )
              : Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _changeMonth(-1),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appTitleText,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _monthLabel(_selectedMonth),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _searchQuery = '';
                    _isSearching = false;
                  } else {
                    _isSearching = true;
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              tooltip: isArabic ? 'الإعدادات واللغة' : 'Settings & Currency',
              onPressed: _openSettingsSheet,
            ),
            IconButton(
              icon: const Icon(Icons.autorenew_rounded),
              tooltip: isArabic ? 'استيراد الفواتير المتكررة' : 'Import Recurring Bills',
              onPressed: _copyPreviousMonthRecurring,
            ),
          ],
        ),
        body: Column(
          children: [
            SummaryHeader(
              totalAmount: totalAmount,
              paidAmount: paidAmount,
              totalCount: calculationBills.length,
              paidCount: paidCount,
              monthLabel: _monthLabel(_selectedMonth),
              onMonthTap: _pickMonth,
              isDailyView: _isDailyView,
              onToggleViewMode: (isDaily) {
                setState(() {
                  _isDailyView = isDaily;
                });
              },
              settings: _settings,
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildFilterPill(isArabic ? 'الكل' : 'All', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterPill(isArabic ? 'قيد الانتظار' : 'Pending', 'Pending', color: Colors.blue),
                  const SizedBox(width: 8),
                  _buildFilterPill(isArabic ? 'متأخر' : 'Overdue', 'Overdue', color: Colors.red),
                  const SizedBox(width: 8),
                  _buildFilterPill(isArabic ? 'مدفوع' : 'Paid', 'Paid', color: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: displayedBills.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 48,
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _activeCalculationBills.isEmpty
                                  ? (isArabic
                                      ? 'لا توجد فواتير ${_isDailyView ? "ليوم اليوم" : "لشهر ${_monthLabel(_selectedMonth)}"}'
                                      : 'No bills for ${_isDailyView ? "today" : _monthLabel(_selectedMonth)}')
                                  : (isArabic ? 'لا توجد نتائج مطابقة للبحث' : 'No matching bills found'),
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _activeCalculationBills.isEmpty
                                  ? (isArabic
                                      ? 'اضغط على "+ إضافة فاتورة" لإضافة فواتير جديدة'
                                      : 'Tap "+ Add Bill" to start collecting bills')
                                  : (isArabic ? 'جرب تغيير كلمة البحث أو الفلاتر' : 'Try changing search query or filters'),
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            if (_activeCalculationBills.isEmpty) ...[
                              FilledButton.icon(
                                onPressed: () => _openBillSheet(),
                                icon: const Icon(Icons.add_rounded),
                                label: Text(isArabic ? 'إضافة أول فاتورة' : 'Add Your First Bill'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: displayedBills.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, idx) {
                        final bill = displayedBills[idx];
                        return BillCard(
                          bill: bill,
                          onTogglePaid: (isPaid) => _togglePaid(bill, isPaid),
                          onEdit: () => _openBillSheet(bill),
                          onDelete: () => _deleteBill(bill),
                          settings: _settings,
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openBillSheet(),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            isArabic ? 'إضافة فاتورة' : 'Add Bill',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, String key, {Color? color}) {
    final theme = Theme.of(context);
    final isSelected = _filterType == key;
    final activeColor = color ?? theme.colorScheme.primary;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: activeColor.withOpacity(0.2),
      side: BorderSide(
        color: isSelected
            ? activeColor
            : theme.colorScheme.outlineVariant.withOpacity(0.3),
      ),
      labelStyle: TextStyle(
        color: isSelected ? activeColor : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterType = key;
          });
        }
      },
    );
  }
}
