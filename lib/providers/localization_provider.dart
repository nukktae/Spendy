import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/translations.dart';
import 'settings_provider.dart';

final localizationProvider = Provider<String Function(String)>((ref) {
  final locale = ref.watch(settingsProvider).locale;
  return (String key) => AppTranslations.get(key, locale: locale);
}); 