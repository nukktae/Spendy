import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../widgets/modern_card.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    // Get current month's transactions
    final currentMonthTransactions = transactions.where((t) {
      final now = DateTime.now();
      return t.date.month == now.month && t.date.year == now.year;
    }).toList();

    // Get previous month's transactions
    final previousMonthTransactions = transactions.where((t) {
      final now = DateTime.now();
      final previousMonth = DateTime(now.year, now.month - 1);
      return t.date.month == previousMonth.month && t.date.year == previousMonth.year;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthlyComparison(context, currentMonthTransactions, previousMonthTransactions),
              const SizedBox(height: 24),
              _buildCategoryAnalysis(context, currentMonthTransactions),
              const SizedBox(height: 24),
              _buildSpendingTrends(context, transactions),
              const SizedBox(height: 24),
              _buildInsights(context, currentMonthTransactions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyComparison(
    BuildContext context,
    List<Transaction> currentMonth,
    List<Transaction> previousMonth,
  ) {
    final currentMonthTotal = currentMonth.fold<double>(
      0,
      (sum, transaction) => sum + (transaction.isIncome ? 0 : transaction.amount),
    );

    final previousMonthTotal = previousMonth.fold<double>(
      0,
      (sum, transaction) => sum + (transaction.isIncome ? 0 : transaction.amount),
    );

    final percentageChange = previousMonthTotal == 0
        ? 100.0
        : ((currentMonthTotal - previousMonthTotal) / previousMonthTotal * 100);

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Comparison',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Compare your spending with last month',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: math.max(currentMonthTotal, previousMonthTotal) * 1.2,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: 100,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '\$${value.toInt()}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      getTitlesWidget: (value, meta) {
                        final now = DateTime.now();
                        final titles = [
                          DateFormat('MMM').format(DateTime(now.year, now.month - 1)),
                          DateFormat('MMM').format(now),
                        ];
                        return Text(
                          titles[value.toInt()],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: previousMonthTotal,
                        color: Theme.of(context).colorScheme.primary.withAlpha(179),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: math.max(currentMonthTotal, previousMonthTotal) * 1.2,
                          color: Theme.of(context).colorScheme.primary.withAlpha(12),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: currentMonthTotal,
                        color: Theme.of(context).colorScheme.primary,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: math.max(currentMonthTotal, previousMonthTotal) * 1.2,
                          color: Theme.of(context).colorScheme.primary.withAlpha(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change from last month',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  '${percentageChange.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: percentageChange > 0
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAnalysis(BuildContext context, List<Transaction> transactions) {
    final categoryTotals = <String, double>{};
    var totalSpending = 0.0;

    // Calculate totals for each category
    for (final transaction in transactions) {
      if (!transaction.isIncome) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
        totalSpending += transaction.amount;
      }
    }

    final categoryData = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your spending distribution by category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: categoryData.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final data = entry.value;
                  final percentage = (data.value / totalSpending) * 100;
                  return PieChartSectionData(
                    color: AppTheme.chartColors[idx % AppTheme.chartColors.length],
                    value: data.value,
                    title: '${percentage.toStringAsFixed(1)}%',
                    radius: 100,
                    titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...categoryData.asMap().entries.map((entry) {
            final idx = entry.key;
            final data = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.chartColors[idx % AppTheme.chartColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          data.key,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${data.value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSpendingTrends(BuildContext context, List<Transaction> transactions) {
    // Group transactions by day
    final dailySpending = <DateTime, double>{};
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);

    // Initialize all days with 0
    for (var i = 0; i < now.day; i++) {
      dailySpending[startDate.add(Duration(days: i))] = 0;
    }

    // Add actual spending
    for (final transaction in transactions) {
      if (!transaction.isIncome && transaction.date.month == now.month) {
        final date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
        dailySpending[date] = (dailySpending[date] ?? 0) + transaction.amount;
      }
    }

    final spots = dailySpending.entries.map((entry) {
      return FlSpot(entry.key.day.toDouble(), entry.value);
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Spending Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your daily expenses this month',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: 100,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '\$${value.toInt()}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        );
                      },
                      reservedSize: 50,
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: Theme.of(context).colorScheme.surface,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withAlpha(100),
                          Theme.of(context).colorScheme.primary.withAlpha(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(BuildContext context, List<Transaction> transactions) {
    // Calculate insights
    final totalSpending = transactions.where((t) => !t.isIncome).fold<double>(
          0,
          (sum, transaction) => sum + transaction.amount,
        );

    final averageSpending = totalSpending / DateTime.now().day;

    final mostExpensiveTransaction = transactions.where((t) => !t.isIncome).reduce(
          (curr, next) => curr.amount > next.amount ? curr : next,
        );

    final mostFrequentCategory = transactions.where((t) => !t.isIncome).fold<Map<String, int>>(
      {},
      (map, transaction) {
        map[transaction.category] = (map[transaction.category] ?? 0) + 1;
        return map;
      },
    ).entries.reduce((curr, next) => curr.value > next.value ? curr : next).key;

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Insights',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Key metrics for this month',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildInsightItem(
              context,
              'Average Daily Spending',
              '\$${averageSpending.toStringAsFixed(2)}',
              Icons.calendar_today,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildInsightItem(
              context,
              'Largest Expense',
              '\$${mostExpensiveTransaction.amount.toStringAsFixed(2)} - ${mostExpensiveTransaction.title}',
              Icons.arrow_upward,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildInsightItem(
              context,
              'Most Frequent Category',
              mostFrequentCategory,
              Icons.category,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 