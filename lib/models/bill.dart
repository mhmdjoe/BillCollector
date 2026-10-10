import 'package:flutter/material.dart';

enum BillCategory {
  housing,
  utilities,
  subscriptions,
  internetAndPhone,
  creditAndLoans,
  insuranceAndHealth,
  education,
  other;

  String get displayName => getDisplayName(false);

  String getDisplayName(bool isArabic) {
    if (isArabic) {
      switch (this) {
        case BillCategory.housing:
          return 'السكن والإيجار';
        case BillCategory.utilities:
          return 'الكهرباء والماء';
        case BillCategory.subscriptions:
          return 'الاشتراكات';
        case BillCategory.internetAndPhone:
          return 'الإنترنت والهاتف';
        case BillCategory.creditAndLoans:
          return 'البطاقات والقروض';
        case BillCategory.insuranceAndHealth:
          return 'التأمين والصحة';
        case BillCategory.education:
          return 'التعليم والتعليمي';
        case BillCategory.other:
          return 'مصاريف أخرى';
      }
    } else {
      switch (this) {
        case BillCategory.housing:
          return 'Housing & Rent';
        case BillCategory.utilities:
          return 'Electricity & Water';
        case BillCategory.subscriptions:
          return 'Subscriptions';
        case BillCategory.internetAndPhone:
          return 'Internet & Mobile';
        case BillCategory.creditAndLoans:
          return 'Cards & Loans';
        case BillCategory.insuranceAndHealth:
          return 'Insurance & Health';
        case BillCategory.education:
          return 'Education';
        case BillCategory.other:
          return 'Other Expenses';
      }
    }
  }

  IconData get icon {
    switch (this) {
      case BillCategory.housing:
        return Icons.home_rounded;
      case BillCategory.utilities:
        return Icons.bolt_rounded;
      case BillCategory.subscriptions:
        return Icons.movie_rounded;
      case BillCategory.internetAndPhone:
        return Icons.wifi_rounded;
      case BillCategory.creditAndLoans:
        return Icons.credit_card_rounded;
      case BillCategory.insuranceAndHealth:
        return Icons.health_and_safety_rounded;
      case BillCategory.education:
        return Icons.school_rounded;
      case BillCategory.other:
        return Icons.widgets_rounded;
    }
  }

  Color get color {
    switch (this) {
      case BillCategory.housing:
        return const Color(0xFF2196F3);
      case BillCategory.utilities:
        return const Color(0xFFFF9800);
      case BillCategory.subscriptions:
        return const Color(0xFF9C27B0);
      case BillCategory.internetAndPhone:
        return const Color(0xFF009688);
      case BillCategory.creditAndLoans:
        return const Color(0xFFF44336);
      case BillCategory.insuranceAndHealth:
        return const Color(0xFF10B981);
      case BillCategory.education:
        return const Color(0xFF6366F1);
      case BillCategory.other:
        return const Color(0xFF64748B);
    }
  }
}

enum BillStatus {
  paid,
  overdue,
  dueToday,
  pending;

  String get label => getLabel(false);

  String getLabel(bool isArabic) {
    if (isArabic) {
      switch (this) {
        case BillStatus.paid:
          return 'مدفوع';
        case BillStatus.overdue:
          return 'متأخر';
        case BillStatus.dueToday:
          return 'مستحق اليوم';
        case BillStatus.pending:
          return 'قيد الانتظار';
      }
    } else {
      switch (this) {
        case BillStatus.paid:
          return 'PAID';
        case BillStatus.overdue:
          return 'OVERDUE';
        case BillStatus.dueToday:
          return 'DUE TODAY';
        case BillStatus.pending:
          return 'PENDING';
      }
    }
  }

  Color get color {
    switch (this) {
      case BillStatus.paid:
        return const Color(0xFF10B981);
      case BillStatus.overdue:
        return const Color(0xFFEF4444);
      case BillStatus.dueToday:
        return const Color(0xFFF59E0B);
      case BillStatus.pending:
        return const Color(0xFF3B82F6);
    }
  }
}

class Bill {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final BillCategory category;
  final bool isPaid;
  final bool isRecurring;
  final String? notes;
  final String? imagePath;

  Bill({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.isPaid = false,
    this.isRecurring = true,
    this.notes,
    this.imagePath,
  });

  BillStatus get status {
    if (isPaid) return BillStatus.paid;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final diffDays = due.difference(today).inDays;

    if (diffDays < 0) {
      return BillStatus.overdue;
    } else if (diffDays == 0) {
      return BillStatus.dueToday;
    } else {
      return BillStatus.pending;
    }
  }

  Bill copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    BillCategory? category,
    bool? isPaid,
    bool? isRecurring,
    String? notes,
    String? imagePath,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isPaid: isPaid ?? this.isPaid,
      isRecurring: isRecurring ?? this.isRecurring,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'category': category.name,
        'isPaid': isPaid,
        'isRecurring': isRecurring,
        'notes': notes,
        'imagePath': imagePath,
      };

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      category: BillCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => BillCategory.other,
      ),
      isPaid: json['isPaid'] ?? false,
      isRecurring: json['isRecurring'] ?? true,
      notes: json['notes'],
      imagePath: json['imagePath'],
    );
  }
}
