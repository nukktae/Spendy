import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_settings.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import 'transaction_provider.dart';
import 'budget_provider.dart';

final settingsBoxProvider = Provider<Box<UserSettings>>((ref) {
  throw UnimplementedError();
});

final settingsProvider = NotifierProvider<SettingsNotifier, UserSettings>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<UserSettings> {
  @override
  UserSettings build() {
    final box = ref.watch(settingsBoxProvider);
    return box.get('settings') ?? UserSettings(
      currency: 'MNT',
      locale: 'mn_MN',
      isDarkMode: false,
      notificationsEnabled: true,
      budgetAlerts: true,
      weeklyReports: true,
    );
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
    _saveSettings();
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
    _saveSettings();
  }

  void updateCurrency(String currency) {
    state = state.copyWith(currency: currency);
    _saveSettings();
  }

  void updateLocale(String locale) {
    state = state.copyWith(locale: locale);
    _saveSettings();
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _saveSettings();
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    _saveSettings();
  }

  void toggleBudgetAlerts() {
    state = state.copyWith(budgetAlerts: !state.budgetAlerts);
    _saveSettings();
  }

  void toggleWeeklyReports() {
    state = state.copyWith(weeklyReports: !state.weeklyReports);
    _saveSettings();
  }

  Future<void> backupData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/money_tracker_backup.json');
    
    final data = {
      'settings': state.toJson(),
      // Add other data to backup here
    };
    
    await file.writeAsString(jsonEncode(data));
    state = state.copyWith(lastBackup: DateTime.now());
    _saveSettings();
  }

  Future<void> restoreData(String filePath) async {
    final file = File(filePath);
    final data = jsonDecode(await file.readAsString());
    
    if (data['settings'] != null) {
      state = UserSettings.fromJson(data['settings']);
      _saveSettings();
    }
    
    // Restore other data here
  }

  void _saveSettings() {
    final box = ref.read(settingsBoxProvider);
    box.put('settings', state);
  }
} 