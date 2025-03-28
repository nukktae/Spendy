import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import 'transaction_provider.dart';

final budgetBoxProvider = Provider<Box<Budget>>((ref) {
  throw UnimplementedError('Budget box must be initialized');
});

final budgetsProvider = NotifierProvider<BudgetsNotifier, List<Budget>>(BudgetsNotifier.new);

class BudgetsNotifier extends Notifier<List<Budget>> {
  late final Box<Budget> _budgetBox;

  @override
  List<Budget> build() {
    _budgetBox = ref.watch(budgetBoxProvider);
    return _budgetBox.values.toList();
  }

  Future<void> addBudget(Budget budget) async {
    await _budgetBox.add(budget);
    state = _budgetBox.values.toList();
  }

  Future<void> updateBudget(Budget budget) async {
    await budget.save();
    state = _budgetBox.values.toList();
  }

  Future<void> deleteBudget(Budget budget) async {
    await budget.delete();
    state = _budgetBox.values.toList();
  }

  double getSpentAmount(String category, DateTime startDate, DateTime endDate) {
    final transactions = ref.read(transactionsProvider);
    return transactions
        .where((t) =>
            !t.isIncome &&
            t.category == category &&
            t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            t.date.isBefore(endDate.add(const Duration(days: 1))))
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  List<Map<String, dynamic>> getBudgetStatus() {
    final now = DateTime.now();
    return state.map((budget) {
      final spent = getSpentAmount(budget.category, budget.startDate, budget.endDate);
      final progress = budget.getProgress(spent);
      final isOverBudget = budget.isOverBudget(spent);
      final isNearThreshold = budget.isNearThreshold(spent);
      
      return {
        'budget': budget,
        'spent': spent,
        'progress': progress,
        'isOverBudget': isOverBudget,
        'isNearThreshold': isNearThreshold,
        'isActive': now.isAfter(budget.startDate) && now.isBefore(budget.endDate),
      };
    }).toList();
  }
} 