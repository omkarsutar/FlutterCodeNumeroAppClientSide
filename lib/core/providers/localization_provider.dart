import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile_state_provider.dart';
import 'auth_providers.dart';

enum AppLanguage { english, hindi, marathi }

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

class LanguageNotifier extends Notifier<AppLanguage> {
  static const String _prefKey = 'user_language';
  static const String _hasSetKey = 'has_set_language';

  @override
  AppLanguage build() {
    final prefsAsync = ref.watch(sharedPrefsProvider);
    final profile = ref.watch(userProfileStateProvider).profile;

    // 1. Priority: Local Storage (SharedPreferences)
    if (prefsAsync.hasValue) {
      final prefs = prefsAsync.value!;
      final localCode = prefs.getString(_prefKey);
      if (localCode != null) {
        return _mapCodeToLanguage(localCode);
      }
    }

    // 2. Priority: User Profile (DB)
    if (profile?.userLanguage != null) {
      final lang = _mapCodeToLanguage(profile!.userLanguage!);
      // Sync to local storage if prefs are ready
      if (prefsAsync.hasValue) {
        _saveToLocal(lang, silent: true);
      }
      return lang;
    }

    return AppLanguage.english; // Default fallback
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
    // If already set to this language AND marked as hasSetLanguage, skip
    final prefs = ref.read(sharedPrefsProvider).value;
    final hasSet = prefs?.getBool(_hasSetKey) ?? false;
    
    if (state == lang && hasSet) return;
    
    state = lang;
    await _saveToLocal(lang);

    // Persist to Supabase if logged in
    final authService = ref.read(authServiceProvider);
    if (authService.currentUser != null) {
      await authService.updateUserLanguage(lang);
    }
  }

  Future<void> _saveToLocal(AppLanguage lang, {bool silent = false}) async {
    final prefs = ref.read(sharedPrefsProvider).value ?? 
                 await SharedPreferences.getInstance();
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
        return 'en';
    }
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(() {
  return LanguageNotifier();
});

final isLanguageSetProvider = Provider<bool>((ref) {
  final prefsAsync = ref.watch(sharedPrefsProvider);
  final profile = ref.watch(userProfileStateProvider).profile;
  
  // While loading prefs, assume it's set to avoid dialog flickers
  if (prefsAsync.isLoading) return true;
  
  final prefs = prefsAsync.value;
  if (prefs != null && prefs.getBool('has_set_language') == true) {
    return true;
  }
  
  if (profile?.userLanguage != null) {
    return true;
  }
  
  return false;
});
