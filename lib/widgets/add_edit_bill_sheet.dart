import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/bill.dart';

class AddEditBillSheet extends StatefulWidget {
  final Bill? initialBill;
  final DateTime initialMonth;
  final ValueChanged<Bill> onSave;
  final AppSettings settings;

  const AddEditBillSheet({
    super.key,
    this.initialBill,
    required this.initialMonth,
    required this.onSave,
    required this.settings,
  });

  @override
  State<AddEditBillSheet> createState() => _AddEditBillSheetState();
}

class _AddEditBillSheetState extends State<AddEditBillSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  late BillCategory _selectedCategory;
  late DateTime _selectedDueDate;
  late bool _isPaid;
  late bool _isRecurring;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final bill = widget.initialBill;
    _titleController = TextEditingController(text: bill?.title ?? '');
    _amountController = TextEditingController(
      text: bill != null ? bill.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: bill?.notes ?? '');

    _selectedCategory = bill?.category ?? BillCategory.housing;
    _selectedDueDate = bill?.dueDate ??
        DateTime(
          widget.initialMonth.year,
          widget.initialMonth.month,
          DateTime.now().day.clamp(1, 28),
        );
    _isPaid = bill?.isPaid ?? false;
    _isRecurring = bill?.isRecurring ?? true;
    _imagePath = bill?.imagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _attachPhotoDialog() {
    final pathController = TextEditingController(text: _imagePath ?? '');
    final isArabic = widget.settings.isArabic;

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: widget.settings.textDirection,
          child: AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.camera_alt_rounded, color: Colors.teal),
                const SizedBox(width: 8),
                Text(isArabic ? 'صورة الفاتورة / الإيصال' : 'Bill Photo / Receipt'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic
                      ? 'أدخل مسار صورة الإيصال أو الصورة الملتقطة:'
                      : 'Enter local image file path or photo URI:',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pathController,
                  decoration: InputDecoration(
                    labelText: isArabic ? 'مسار الملف' : 'Image File Path',
                    hintText: 'e.g., /sdcard/Download/receipt.jpg',
                    prefixIcon: const Icon(Icons.insert_photo_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(isArabic ? 'إلغاء' : 'Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final path = pathController.text.trim();
                  setState(() {
                    _imagePath = path.isNotEmpty ? path : null;
                  });
                  Navigator.pop(context);
                },
                child: Text(isArabic ? 'إرفاق الصورة' : 'Attach Photo'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final notes = _notesController.text.trim();

      final updatedBill = Bill(
        id: widget.initialBill?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        dueDate: _selectedDueDate,
        category: _selectedCategory,
        isPaid: _isPaid,
        isRecurring: _isRecurring,
        notes: notes.isNotEmpty ? notes : null,
        imagePath: _imagePath,
      );

      widget.onSave(updatedBill);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialBill != null;
    final isArabic = widget.settings.isArabic;
    final currencySymbol = widget.settings.currency.symbol;

    return Directionality(
      textDirection: widget.settings.textDirection,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing
                            ? (isArabic ? 'تعديل الفاتورة' : 'Edit Bill Details')
                            : (isArabic ? 'إضافة فاتورة جديدة' : 'Add New Bill'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم الفاتورة' : 'Bill Name',
                      hintText: isArabic ? 'مثال: إيجار الشقة، فاتورة الكهرباء' : 'e.g., Rent, Electric Bill',
                      prefixIcon: const Icon(Icons.receipt_long_rounded),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return isArabic ? 'يرجى إدخال اسم الفاتورة' : 'Please enter a bill name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: isArabic ? 'المبلغ ($currencySymbol)' : 'Amount ($currencySymbol)',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money_rounded),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return isArabic ? 'يرجى إدخال المبلغ' : 'Please enter an amount';
                      }
                      if (double.tryParse(val.trim()) == null) {
                        return isArabic ? 'يرجى إدخال رقم صحيح' : 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isArabic ? 'الفئة' : 'Category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 42,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: BillCategory.values.length,
                      itemBuilder: (context, index) {
                        final cat = BillCategory.values[index];
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            avatar: Icon(
                              cat.icon,
                              size: 16,
                              color: isSelected ? Colors.white : cat.color,
                            ),
                            label: Text(cat.getDisplayName(isArabic)),
                            selected: isSelected,
                            selectedColor: cat.color,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Due Date Selector
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'تاريخ الاستحقاق' : 'Due Date',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  Text(
                                    '${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bill Photo Section
                  Text(
                    isArabic ? 'صورة الفاتورة / الإيصال' : 'Bill Photo / Receipt',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_imagePath != null && _imagePath!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.photo_rounded, color: Colors.teal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${isArabic ? "تم إرفاق الصورة:" : "Photo attached:"} ${_imagePath!.split('/').last}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              setState(() {
                                _imagePath = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _attachPhotoDialog,
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: Text(_imagePath != null
                          ? (isArabic ? 'تغيير صورة الفاتورة' : 'Change Bill Photo')
                          : (isArabic ? 'إلتقاط / إرفاق صورة الإيصال' : 'Attach Bill Photo / Receipt')),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(isArabic ? 'تكرار شهري' : 'Monthly Recurring'),
                    subtitle: Text(isArabic ? 'يتكرر تلقائياً كل شهر' : 'Repeats automatically every month'),
                    value: _isRecurring,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      setState(() {
                        _isRecurring = val;
                      });
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(isArabic ? 'تحديد كمدفوع' : 'Mark as Paid'),
                    value: _isPaid,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() {
                        _isPaid = val;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'ملاحظات (اختياري)' : 'Notes (Optional)',
                      prefixIcon: const Icon(Icons.notes_rounded),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: Text(
                        isEditing ? (isArabic ? 'حفظ التعديلات' : 'Save Changes') : (isArabic ? 'إضافة الفاتورة' : 'Add Bill'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
