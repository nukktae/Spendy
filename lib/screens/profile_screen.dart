import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/settings_provider.dart';
import '../providers/localization_provider.dart';
import '../widgets/modern_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final t = ref.watch(localizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('profile')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context, ref),
          const SizedBox(height: 16),
          _buildPreferencesSection(context, ref),
          const SizedBox(height: 16),
          _buildNotificationsSection(context, ref),
          const SizedBox(height: 16),
          _buildBackupSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final t = ref.watch(localizationProvider);

    return ModernCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              settings.name.isNotEmpty
                  ? settings.name[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            settings.name.isNotEmpty ? settings.name : t('guest'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (settings.email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              settings.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _showEditProfileDialog(context, ref),
            icon: const Icon(Icons.edit),
            label: Text(t('edit_profile')),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final t = ref.watch(localizationProvider);

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('preferences'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: Text(t('currency')),
            subtitle: Text(settings.currency),
            onTap: () => _showCurrencyPicker(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(t('language')),
            subtitle: Text(_getLanguageName(settings.locale)),
            onTap: () => _showLanguagePicker(context, ref),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(t('dark_mode')),
            value: settings.isDarkMode,
            onChanged: (_) => ref.read(settingsProvider.notifier).toggleDarkMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final t = ref.watch(localizationProvider);

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('notifications'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: Text(t('enable_notifications')),
            value: settings.notificationsEnabled,
            onChanged: (_) =>
                ref.read(settingsProvider.notifier).toggleNotifications(),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.warning),
            title: Text(t('budget_alerts')),
            value: settings.budgetAlerts,
            activeColor: settings.notificationsEnabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            onChanged: settings.notificationsEnabled
                ? (_) => ref.read(settingsProvider.notifier).toggleBudgetAlerts()
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.summarize),
            title: Text(t('weekly_reports')),
            value: settings.weeklyReports,
            activeColor: settings.notificationsEnabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            onChanged: settings.notificationsEnabled
                ? (_) => ref.read(settingsProvider.notifier).toggleWeeklyReports()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final t = ref.watch(localizationProvider);

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('backup'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(t('backup_data')),
            subtitle: Text('${t('last_backup')}: ${_formatDate(settings.lastBackup)}'),
            onTap: () => _backupData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(t('restore_data')),
            onTap: () => _restoreData(context, ref),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    final t = ref.watch(localizationProvider);
    final nameController = TextEditingController(text: settings.name);
    final emailController = TextEditingController(text: settings.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('edit_profile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: t('name'),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: t('email'),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).updateName(nameController.text);
              ref
                  .read(settingsProvider.notifier)
                  .updateEmail(emailController.text);
              Navigator.pop(context);
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final currencies = [
      {'code': 'MNT', 'name': 'Mongolian Tugrik (₮)'},
      {'code': 'USD', 'name': 'US Dollar (\$)'},
      {'code': 'EUR', 'name': 'Euro (€)'},
      {'code': 'GBP', 'name': 'British Pound (£)'},
      {'code': 'JPY', 'name': 'Japanese Yen (¥)'},
      {'code': 'AUD', 'name': 'Australian Dollar (A\$)'},
      {'code': 'CAD', 'name': 'Canadian Dollar (C\$)'},
      {'code': 'CHF', 'name': 'Swiss Franc (Fr)'},
      {'code': 'CNY', 'name': 'Chinese Yuan (¥)'},
      {'code': 'INR', 'name': 'Indian Rupee (₹)'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              ref.watch(localizationProvider)('currency'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected =
                    ref.watch(settingsProvider).currency == currency['code'];
                return ListTile(
                  leading: isSelected
                      ? Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary)
                      : const SizedBox(width: 24),
                  title: Text(currency['name']!),
                  onTap: () {
                    ref
                        .read(settingsProvider.notifier)
                        .updateCurrency(currency['code']!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final locales = [
      {'code': 'mn_MN', 'name': 'Монгол'},
      {'code': 'en_US', 'name': 'English'},
      {'code': 'es_ES', 'name': 'Español'},
      {'code': 'fr_FR', 'name': 'Français'},
      {'code': 'de_DE', 'name': 'Deutsch'},
      {'code': 'it_IT', 'name': 'Italiano'},
      {'code': 'ja_JP', 'name': '日本語'},
      {'code': 'ko_KR', 'name': '한국어'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              ref.watch(localizationProvider)('language'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: locales.length,
              itemBuilder: (context, index) {
                final locale = locales[index];
                final isSelected =
                    ref.watch(settingsProvider).locale == locale['code'];
                return ListTile(
                  leading: isSelected
                      ? Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary)
                      : const SizedBox(width: 24),
                  title: Text(locale['name']!),
                  onTap: () {
                    ref
                        .read(settingsProvider.notifier)
                        .updateLocale(locale['code']!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(settingsProvider.notifier).backupData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.watch(localizationProvider)('backup_success')),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.watch(localizationProvider)('backup_error')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _restoreData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        await ref
            .read(settingsProvider.notifier)
            .restoreData(result.files.single.path!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ref.watch(localizationProvider)('restore_success')),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.watch(localizationProvider)('restore_error')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _getLanguageName(String locale) {
    switch (locale) {
      case 'mn_MN':
        return 'Монгол';
      case 'en_US':
        return 'English';
      case 'es_ES':
        return 'Español';
      case 'fr_FR':
        return 'Français';
      case 'de_DE':
        return 'Deutsch';
      case 'it_IT':
        return 'Italiano';
      case 'ja_JP':
        return '日本語';
      case 'ko_KR':
        return '한국어';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 