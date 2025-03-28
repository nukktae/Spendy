import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../services/ai_service.dart';
import '../widgets/modern_card.dart';
import '../widgets/modern_button.dart';
import '../widgets/modern_input_field.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final bool isIncome;
  
  const AddTransactionScreen({
    super.key,
    this.isIncome = false,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late bool _isIncome;
  String _selectedCategory = 'Other';
  final _aiService = AIService();

  final List<String> _categories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Bills & Utilities',
    'Entertainment',
    'Health',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _isIncome = widget.isIncome;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _scanReceipt() async {
    final result = await _aiService.scanReceipt();
    if (result.isNotEmpty) {
      setState(() {
        _titleController.text = result['merchantName'] ?? '';
        _amountController.text = result['totalAmount']?.toString() ?? '';
        _selectedCategory = _aiService.categorizeTransaction(
          _titleController.text,
          double.tryParse(_amountController.text) ?? 0,
        );
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: const Uuid().v4(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: DateTime.now(),
        category: _selectedCategory,
        isIncome: _isIncome,
        note: _noteController.text,
      );

      ref.read(transactionsProvider.notifier).addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add ${_isIncome ? 'Income' : 'Expense'}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModernCard(
                child: Row(
                  children: [
                    Expanded(
                      child: ModernButton(
                        text: 'Income',
                        icon: Icons.add,
                        backgroundColor: _isIncome
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        textColor: _isIncome
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        onPressed: _isIncome
                            ? null
                            : () => setState(() => _isIncome = true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ModernButton(
                        text: 'Expense',
                        icon: Icons.remove,
                        backgroundColor: !_isIncome
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.surface,
                        textColor: !_isIncome
                            ? Theme.of(context).colorScheme.onError
                            : Theme.of(context).colorScheme.onSurface,
                        onPressed: _isIncome
                            ? () => setState(() => _isIncome = false)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Title',
                hint: 'Enter transaction title',
                controller: _titleController,
                prefix: const Icon(Icons.title),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Amount',
                hint: 'Enter amount',
                controller: _amountController,
                prefix: const Icon(Icons.attach_money),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Category',
                hint: 'Select category',
                controller: TextEditingController(text: _selectedCategory),
                prefix: const Icon(Icons.category),
                suffix: DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              ModernInputField(
                label: 'Note (Optional)',
                hint: 'Add a note about this transaction',
                controller: _noteController,
                prefix: const Icon(Icons.note),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ModernButton(
                text: 'Scan Receipt',
                icon: Icons.receipt_long,
                onPressed: _scanReceipt,
              ),
              const SizedBox(height: 16),
              ModernButton(
                text: 'Add Transaction',
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 