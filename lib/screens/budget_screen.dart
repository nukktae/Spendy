import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../providers/budget_provider.dart';
import '../providers/localization_provider.dart';
import '../widgets/modern_card.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);
    final budgetStatus = ref.read(budgetsProvider.notifier).getBudgetStatus();
    final t = ref.watch(localizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('budget.title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: SafeArea(
        child: budgetStatus.isEmpty
            ? _buildEmptyState(context, t)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: budgetStatus.length,
                itemBuilder: (context, index) {
                  final status = budgetStatus[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildBudgetCard(context, status, t),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBudgetDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(t('budget.addBudget')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String Function(String) t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            t('budget.noBudgets'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            t('budget.emptyStateMessage'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, Map<String, dynamic> status, String Function(String) t) {
    final budget = status['budget'] as Budget;
    final spent = status['spent'] as double;
    final progress = status['progress'] as double;
    final isOverBudget = status['isOverBudget'] as bool;
    final isNearThreshold = status['isNearThreshold'] as bool;
    final isActive = status['isActive'] as bool;

    final progressColor = isOverBudget
        ? Theme.of(context).colorScheme.error
        : isNearThreshold
            ? Theme.of(context).colorScheme.error.withAlpha(150)
            : Theme.of(context).colorScheme.primary;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    budget.category,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    DateFormat('MMM d').format(budget.startDate) +
                        ' - ' +
                        DateFormat('MMM d').format(budget.endDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? Theme.of(context).colorScheme.primary.withAlpha(12)
                      : Theme.of(context).colorScheme.error.withAlpha(12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? t('budget.active') : t('budget.expired'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: progressColor.withAlpha(24),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₮${spent.toStringAsFixed(2)} ${t('budget.spent')}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                '${t('budget.of')} ₮${budget.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          if (isOverBudget || isNearThreshold) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: progressColor.withAlpha(12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverBudget ? Icons.warning : Icons.info_outline,
                    color: progressColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isOverBudget
                          ? t('budget.overBudgetWarning')
                          : t('budget.nearBudgetWarning'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddBudgetSheet(),
    );
  }
}

class AddBudgetSheet extends ConsumerStatefulWidget {
  const AddBudgetSheet({super.key});

  @override
  ConsumerState<AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends ConsumerState<AddBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categoryController;
  late TextEditingController _amountController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _notificationsEnabled = true;
  double _warningThreshold = 80;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController();
    _amountController = TextEditingController();
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(localizationProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('budget.addNewBudget'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: t('budget.category'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t('budget.categoryRequired');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: t('budget.amount'),
                border: const OutlineInputBorder(),
                prefixText: '₮',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t('budget.amountRequired');
                }
                if (double.tryParse(value) == null) {
                  return t('budget.invalidAmount');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(t('budget.enableNotifications')),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final budget = Budget(
                      category: _categoryController.text,
                      amount: double.parse(_amountController.text),
                      startDate: _startDate,
                      endDate: _endDate,
                      notificationsEnabled: _notificationsEnabled,
                      warningThreshold: _warningThreshold,
                    );
                    ref.read(budgetsProvider.notifier).addBudget(budget);
                    Navigator.pop(context);
                  }
                },
                child: Text(t('budget.save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 