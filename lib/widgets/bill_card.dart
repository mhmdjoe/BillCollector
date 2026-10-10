import 'dart:io';
import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/bill.dart';

class BillCard extends StatefulWidget {
  final Bill bill;
  final ValueChanged<bool> onTogglePaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final AppSettings settings;

  const BillCard({
    super.key,
    required this.bill,
    required this.onTogglePaid,
    required this.onEdit,
    required this.onDelete,
    required this.settings,
  });

  @override
  State<BillCard> createState() => _BillCardState();
}

class _BillCardState extends State<BillCard> {
  bool _isExpanded = false;

  String _formatDate(DateTime date) {
    final monthsEn = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final monthsAr = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];

    final monthName = widget.settings.isArabic
        ? monthsAr[date.month - 1]
        : monthsEn[date.month - 1];

    return '$monthName ${date.day}, ${date.year}';
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(widget.bill.title),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              InteractiveViewer(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bill = widget.bill;
    final category = bill.category;
    final status = bill.status;
    final isArabic = widget.settings.isArabic;
    final currencySymbol = widget.settings.currency.symbol;

    final catText = category.getDisplayName(isArabic);
    final stText = status.getLabel(isArabic);

    final deleteText = isArabic ? 'حذف' : 'Delete';
    final markPaidText = isArabic ? 'تحديد كمدفوع' : 'Mark as Paid';
    final markUnpaidText = isArabic ? 'تحديد كغير مدفوع' : 'Mark Unpaid';

    return Dismissible(
      key: Key(bill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              deleteText,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.delete_outline_rounded,
              color: theme.colorScheme.onErrorContainer,
            ),
          ],
        ),
      ),
      onDismissed: (_) => widget.onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: _isExpanded
                ? theme.colorScheme.primary.withOpacity(0.5)
                : theme.colorScheme.outlineVariant.withOpacity(0.4),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    // Category Avatar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title and details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  bill.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    decoration: bill.isPaid
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: bill.isPaid
                                        ? theme.colorScheme.onSurface.withOpacity(0.5)
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              if (bill.imagePath != null &&
                                  File(bill.imagePath!).existsSync())
                                const Icon(
                                  Icons.photo_rounded,
                                  size: 16,
                                  color: Colors.teal,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                catText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '•  ${_formatDate(bill.dueDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Amount and status badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$currencySymbol${bill.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: bill.isPaid
                                ? Colors.grey
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: status.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: status.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Expanded Action Section
                if (_isExpanded) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  if (bill.notes != null && bill.notes!.isNotEmpty) ...[
                    Align(
                      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        '${isArabic ? "ملاحظة:" : "Note:"} ${bill.notes!}',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  // Bill Image Thumbnail
                  if (bill.imagePath != null &&
                      File(bill.imagePath!).existsSync()) ...[
                    Align(
                      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                      child: InkWell(
                        onTap: () =>
                            _showImageDialog(context, bill.imagePath!),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Image.file(
                                File(bill.imagePath!),
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                color: Colors.black54,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isArabic ? 'عرض الصورة' : 'View Photo',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => widget.onTogglePaid(!bill.isPaid),
                          style: FilledButton.styleFrom(
                            backgroundColor: bill.isPaid
                                ? theme.colorScheme.surfaceVariant
                                : const Color(0xFF10B981),
                            foregroundColor: bill.isPaid
                                ? theme.colorScheme.onSurface
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(
                            bill.isPaid
                                ? Icons.undo_rounded
                                : Icons.check_circle_rounded,
                            size: 16,
                          ),
                          label: Text(
                            bill.isPaid ? markUnpaidText : markPaidText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        tooltip: isArabic ? 'تعديل' : 'Edit',
                      ),
                      const SizedBox(width: 4),
                      IconButton.filledTonal(
                        onPressed: widget.onDelete,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.error,
                        ),
                        tooltip: isArabic ? 'حذف' : 'Delete',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
