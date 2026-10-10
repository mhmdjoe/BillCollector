import 'package:flutter/material.dart';

import '../models/app_settings.dart';

class SummaryHeader extends StatelessWidget {
  final double totalAmount;
  final double paidAmount;
  final int totalCount;
  final int paidCount;
  final String monthLabel;
  final VoidCallback onMonthTap;
  final bool isDailyView;
  final ValueChanged<bool> onToggleViewMode;
  final AppSettings settings;

  const SummaryHeader({
    super.key,
    required this.totalAmount,
    required this.paidAmount,
    required this.totalCount,
    required this.paidCount,
    required this.monthLabel,
    required this.onMonthTap,
    required this.isDailyView,
    required this.onToggleViewMode,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = settings.isArabic;
    final currencySymbol = settings.currency.symbol;

    final remainingAmount = (totalAmount - paidAmount).clamp(0.0, double.infinity);
    final progress = totalAmount > 0 ? (paidAmount / totalAmount).clamp(0.0, 1.0) : 0.0;
    final percentageInt = (progress * 100).round();

    final titleText = isDailyView
        ? (isArabic ? 'إجمالي الفواتير اليومية' : 'Total Daily Bills')
        : (isArabic ? 'إجمالي الفواتير الشهرية' : 'Total Monthly Bills');

    final paidLabel = isArabic ? 'المدفوع' : 'Paid';
    final remainingLabel = isArabic ? 'المتبقي' : 'Remaining';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Month Selector Button
              InkWell(
                onTap: onMonthTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        monthLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              // Daily vs Monthly Mode Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildModeButton(
                      label: isArabic ? 'يومي' : 'Daily',
                      isSelected: isDailyView,
                      onTap: () => onToggleViewMode(true),
                    ),
                    _buildModeButton(
                      label: isArabic ? 'شهري' : 'Monthly',
                      isSelected: !isDailyView,
                      onTap: () => onToggleViewMode(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            titleText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$currencySymbol${totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(paidLabel, '$currencySymbol${paidAmount.toStringAsFixed(2)}', Colors.lightGreenAccent),
              _buildStatItem(remainingLabel, '$currencySymbol${remainingAmount.toStringAsFixed(2)}', Colors.amberAccent),
              _buildStatItem(
                isArabic ? 'الإنجاز' : 'Progress',
                '$paidCount/$totalCount ($percentageInt%)',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.teal.shade900 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
