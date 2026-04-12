import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_orchestrators.dart';
import 'core/config/supabase_config.dart';
import 'core/globals.dart';
import 'core/utils/platform/web_utils.dart';
import 'router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/messaging_service.dart';
import 'core/services/analytics_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for the background isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('Firebase initialized successfully');

  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
    );
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  if (kIsWeb) {
    try {
      final translatedUtmSource = webUtils.getUtmSource();
      if (translatedUtmSource != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('utm_source', translatedUtmSource);
        debugPrint('UTM Source translated and saved: $translatedUtmSource');
      }

      Stream.periodic(const Duration(seconds: 10)).listen((_) {
        webUtils.logMemoryDiagnostics();
      });
    } catch (e) {
      debugPrint('Error in web diagnostics: $e');
    }
  }

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return SelectableText(
      details.exceptionAsString(),
      style: const TextStyle(color: Color(0xFFE53935), fontSize: 14),
    );
  };

  final container = ProviderContainer();
  // Initialize messaging in background to avoid blocking the UI startup
  container.read(messagingServiceProvider).initialize();


  runApp(UncontrolledProviderScope(container: container, child: const MainApp()));

}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return AppOrchestratorScope(
      child: MaterialApp.router(
        title: 'Numero Shastra',
        scaffoldMessengerKey: scaffoldMessengerKey,
        routerConfig: router,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF673AB7),
            brightness: Brightness.light,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color(0xFFF3E5F5),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: const Color(0xFFF3E5F5),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Color(0xFF673AB7),
            foregroundColor: Colors.white,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: const Color(0xFFFFC107),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
