import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';

final transactionBoxProvider = Provider<Box<Transaction>>((ref) {
  throw UnimplementedError();
});

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  final box = ref.watch(transactionBoxProvider);
  return TransactionsNotifier(box);
});

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final Box<Transaction> _box;

  TransactionsNotifier(this._box) : super([]) {
    _loadTransactions();
  }

  void _loadTransactions() {
    state = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    _loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    _loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    _loadTransactions();
  }

  double get totalBalance {
    return state.fold(0, (sum, transaction) {
      return sum + (transaction.isIncome ? transaction.amount : -transaction.amount);
    });
  }

  double get totalIncome {
    return state
        .where((transaction) => transaction.isIncome)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpenses {
    return state
        .where((transaction) => !transaction.isIncome)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  List<Transaction> get recentTransactions {
    return state.take(5).toList();
  }
} 