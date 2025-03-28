import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 2)
class Budget extends HiveObject {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime startDate;

  @HiveField(3)
  final DateTime endDate;

  @HiveField(4)
  final bool notificationsEnabled;

  @HiveField(5)
  final double warningThreshold; // Percentage (0-100) at which to show warning

  Budget({
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.notificationsEnabled = true,
    this.warningThreshold = 80,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        category: json['category'] as String,
        amount: json['amount'] as double,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        warningThreshold: json['warningThreshold'] as double? ?? 80,
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'amount': amount,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'notificationsEnabled': notificationsEnabled,
        'warningThreshold': warningThreshold,
      };

  double getProgress(double spent) {
    return (spent / amount) * 100;
  }

  bool isOverBudget(double spent) {
    return spent > amount;
  }

  bool isNearThreshold(double spent) {
    final progress = getProgress(spent);
    return progress >= warningThreshold && progress < 100;
  }
} 