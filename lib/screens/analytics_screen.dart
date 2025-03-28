import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/localization_provider.dart';
import '../widgets/modern_card.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final t = ref.watch(localizationProvider);

    // Get current month's transactions
    final currentMonthTransactions = transactions.where((t) {
      final now = DateTime.now();
      return t.date.month == now.month && t.date.year == now.year;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('analytics.title'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInsights(context, currentMonthTransactions, t),
              const SizedBox(height: 24),
              _buildSpendingTrends(context, transactions, t),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingTrends(BuildContext context, List<Transaction> transactions, String Function(String) t) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('analytics.dailySpending'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(now),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t('analytics.thisMonth'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
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
                            '₮${value.toInt()}',
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

  Widget _buildInsights(BuildContext context, List<Transaction> transactions, String Function(String) t) {
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
            t('analytics.monthlyInsights'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
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
              t('analytics.averageDailySpending'),
              '₮${averageSpending.toStringAsFixed(2)}',
              Icons.calendar_today,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildInsightItem(
              context,
              t('analytics.mostExpensiveTransaction'),
              '₮${mostExpensiveTransaction.amount.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildInsightItem(
              context,
              t('analytics.mostFrequentCategory'),
              mostFrequentCategory,
              Icons.category,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, String title, String value, IconData icon) {
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 