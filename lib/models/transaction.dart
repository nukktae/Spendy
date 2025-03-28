import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final bool isIncome;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final String? receiptImagePath;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isIncome,
    this.note,
    this.receiptImagePath,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      isIncome: json['isIncome'] as bool,
      note: json['note'] as String?,
      receiptImagePath: json['receiptImagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'isIncome': isIncome,
      'note': note,
      'receiptImagePath': receiptImagePath,
    };
  }
} 