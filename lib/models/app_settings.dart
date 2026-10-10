import 'package:flutter/material.dart';

enum AppCurrency {
  usd('\$', 'USD - US Dollar'),
  eur('€', 'EUR - Euro'),
  gbp('£', 'GBP - British Pound'),
  egp('EGP', 'EGP - Egyptian Pound'),
  sar('ر.س', 'SAR - Saudi Riyal'),
  aed('د.إ', 'AED - UAE Dirham'),
  iqd('د.ع', 'IQD - Iraqi Dinar');

  final String symbol;
  final String label;

  const AppCurrency(this.symbol, this.label);
}

class AppSettings {
  final String languageCode; // 'en' or 'ar'
  final AppCurrency currency;

  AppSettings({
    this.languageCode = 'en',
    this.currency = AppCurrency.usd,
  });

  bool get isArabic => languageCode == 'ar';
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  AppSettings copyWith({
    String? languageCode,
    AppCurrency? currency,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() => {
        'languageCode': languageCode,
        'currency': currency.name,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      languageCode: json['languageCode'] ?? 'en',
      currency: AppCurrency.values.firstWhere(
        (e) => e.name == json['currency'],
        orElse: () => AppCurrency.usd,
      ),
    );
  }
}
