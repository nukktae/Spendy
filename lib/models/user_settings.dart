import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 3)
class UserSettings extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String email;

  @HiveField(2)
  String currency;

  @HiveField(3)
  String locale;

  @HiveField(4)
  bool isDarkMode;

  @HiveField(5)
  bool notificationsEnabled;

  @HiveField(6)
  bool budgetAlerts;

  @HiveField(7)
  bool weeklyReports;

  @HiveField(8)
  final DateTime lastBackup;

  UserSettings({
    this.name = '',
    this.email = '',
    required this.currency,
    required this.locale,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.budgetAlerts,
    required this.weeklyReports,
    DateTime? lastBackup,
  }) : lastBackup = lastBackup ?? DateTime.now();

  UserSettings copyWith({
    String? name,
    String? email,
    String? currency,
    String? locale,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? budgetAlerts,
    bool? weeklyReports,
    DateTime? lastBackup,
  }) {
    return UserSettings(
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      lastBackup: lastBackup ?? this.lastBackup,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'currency': currency,
        'locale': locale,
        'isDarkMode': isDarkMode,
        'notificationsEnabled': notificationsEnabled,
        'budgetAlerts': budgetAlerts,
        'weeklyReports': weeklyReports,
        'lastBackup': lastBackup.toIso8601String(),
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        name: json['name'] as String,
        email: json['email'] as String,
        currency: json['currency'] as String,
        locale: json['locale'] as String,
        isDarkMode: json['isDarkMode'] as bool,
        notificationsEnabled: json['notificationsEnabled'] as bool,
        budgetAlerts: json['budgetAlerts'] as bool,
        weeklyReports: json['weeklyReports'] as bool,
        lastBackup: json['lastBackup'] != null
            ? DateTime.parse(json['lastBackup'] as String)
            : null,
      );
} 