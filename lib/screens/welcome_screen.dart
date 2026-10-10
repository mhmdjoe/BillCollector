import 'package:flutter/material.dart';

import '../models/app_settings.dart';

class WelcomeScreen extends StatelessWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;
  final VoidCallback onGetStarted;

  const WelcomeScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = settings.isArabic;

    return Directionality(
      textDirection: settings.textDirection,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.tertiary,
                const Color(0xFF0F172A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  // Language & Currency Selector Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Language Toggle Chip
                      InkWell(
                        onTap: () {
                          onSettingsChanged(
                            settings.copyWith(
                              languageCode: isArabic ? 'en' : 'ar',
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.language_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                isArabic ? 'English' : 'العربية',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Currency Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${settings.currency.symbol} (${settings.currency.name.toUpperCase()})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Hero Icon Container
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Welcome Title
                  Text(
                    isArabic ? 'مرحباً بك في جامع الفواتير' : 'Welcome to Bill Collector',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    isArabic
                        ? 'تتبع فواتيرك اليومية والشهرية بسهولة، والتقط صور الإيصالات واحسب مصروفاتك بكل دقة.'
                        : 'Track your daily and monthly bills effortlessly, capture receipt photos, and stay ahead of due dates.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Feature Highlights
                  _buildHighlightRow(
                    icon: Icons.today_rounded,
                    title: isArabic ? 'حسابات يومية وشهرية' : 'Daily & Monthly Totals',
                    subtitle: isArabic
                        ? 'حساب تلقائي للفواتير المستحقة والمدفوعة'
                        : 'Auto-calculate total paid and remaining balance',
                  ),
                  const SizedBox(height: 16),
                  _buildHighlightRow(
                    icon: Icons.camera_alt_rounded,
                    title: isArabic ? 'التقاط صور الإيصالات' : 'Capture Receipt Photos',
                    subtitle: isArabic
                        ? 'احفظ صورة الفاتورة مباشرة مع كل سجل'
                        : 'Attach photo receipts to your bills for reference',
                  ),
                  const SizedBox(height: 16),
                  _buildHighlightRow(
                    icon: Icons.currency_exchange_rounded,
                    title: isArabic ? 'تخصيص العملة واللغة' : 'Multi-Currency & Languages',
                    subtitle: isArabic
                        ? 'دعم كامل للغة العربية والإنجليزية ومختلف العملات'
                        : 'Supports English, Arabic & custom currency symbols',
                  ),
                  const Spacer(),
                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.colorScheme.primary,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        isArabic ? 'البدء الآن' : 'Get Started',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
