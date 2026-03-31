import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_profile_state_provider.dart';
import 'auth_providers.dart';

enum AppLanguage { english, hindi, marathi }

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    // Listen to profile changes to sync language from DB
    final profile = ref.watch(userProfileStateProvider).profile;
    final dbLang = profile?.userLanguage;

    if (dbLang != null) {
      return _mapCodeToLanguage(dbLang);
    }

    return AppLanguage.hindi; // Default language
  }

  void toggleLanguage() {
    AppLanguage next;
    if (state == AppLanguage.english) {
      next = AppLanguage.hindi;
    } else if (state == AppLanguage.hindi) {
      next = AppLanguage.marathi;
    } else {
      next = AppLanguage.english;
    }
    setLanguage(next);
  }

  void setLanguage(AppLanguage lang) {
    if (state == lang) return;
    state = lang;

    // Persist to Supabase if logged in
    final authService = ref.read(authServiceProvider);
    if (authService.currentUser != null) {
      authService.updateUserLanguage(lang);
    }
  }

  AppLanguage _mapCodeToLanguage(String code) {
    switch (code) {
      case 'hi':
        return AppLanguage.hindi;
      case 'mr':
        return AppLanguage.marathi;
      case 'en':
      default:
        return AppLanguage.english;
    }
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(() {
  return LanguageNotifier();
});
