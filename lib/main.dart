import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'models/user_settings.dart';
import 'models/transaction.dart';
import 'models/budget.dart';
import 'providers/settings_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/localization_provider.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(BudgetAdapter());
  
  final transactionBox = await Hive.openBox<Transaction>('transactions');
  final budgetBox = await Hive.openBox<Budget>('budgets');
  final settingsBox = await Hive.openBox<UserSettings>('settings');

  if (settingsBox.isEmpty) {
    await settingsBox.put('settings', UserSettings(
      currency: 'MNT',
      locale: 'mn_MN',
      isDarkMode: false,
      notificationsEnabled: true,
      budgetAlerts: true,
      weeklyReports: true,
    ));
  }

  runApp(
    ProviderScope(
      overrides: [
        settingsBoxProvider.overrideWithValue(settingsBox),
        transactionBoxProvider.overrideWithValue(transactionBox),
        budgetBoxProvider.overrideWithValue(budgetBox),
      ],
      child: const MoneyTrackerApp(),
    ),
  );
}

class MoneyTrackerApp extends ConsumerWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;
    return MaterialApp(
      title: 'Money Tracker AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MainScreen(),
    );
  }
}
