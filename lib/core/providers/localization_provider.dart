import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile_state_provider.dart';
import 'auth_providers.dart';

enum AppLanguage { english, hindi, marathi }

class LanguageNotifier extends Notifier<AppLanguage> {
  static const String _prefKey = 'user_language';
  static const String _hasSetKey = 'has_set_language';
  SharedPreferences? _prefs;

  @override
  AppLanguage build() {
    _initPrefs();

    // 1. Priority: User Profile (DB)
    final profile = ref.watch(userProfileStateProvider).profile;
    final dbLang = profile?.userLanguage;

    if (dbLang != null) {
      final lang = _mapCodeToLanguage(dbLang);
      _saveToLocal(lang, silent: true); // Keep local in sync with DB
      return lang;
    }

    // 2. Priority: Local Storage (SharedPreferences)
    // Note: build() is synchronous, so we check if prefs was already initialized
    // or use a default and let the UI react when prefs are ready.
    final localCode = _prefs?.getString(_prefKey);
    if (localCode != null) {
      return _mapCodeToLanguage(localCode);
    }

    return AppLanguage.english; // Default fallback
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    // Re-trigger build once prefs are loaded to catch local storage
    ref.invalidateSelf();
  }

  bool get hasSetLanguage {
    return _prefs?.getBool(_hasSetKey) ?? false;
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

  Future<void> setLanguage(AppLanguage lang) async {
    if (state == lang && hasSetLanguage) return;
    state = lang;

    await _saveToLocal(lang);

    // Persist to Supabase if logged in
    final authService = ref.read(authServiceProvider);
    if (authService.currentUser != null) {
      await authService.updateUserLanguage(lang);
    }
  }

  Future<void> _saveToLocal(AppLanguage lang, {bool silent = false}) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final code = _mapLanguageToCode(lang);
    await prefs.setString(_prefKey, code);
    if (!silent) {
      await prefs.setBool(_hasSetKey, true);
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

  String _mapLanguageToCode(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.marathi:
        return 'mr';
      case AppLanguage.english:
      default:
        return 'en';
    }
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(() {
  return LanguageNotifier();
});

final isLanguageSetProvider = Provider<bool>((ref) {
  // We need to watch the notifier state to re-evaluate when language is set
  ref.watch(languageProvider);
  return ref.read(languageProvider.notifier).hasSetLanguage;
});
