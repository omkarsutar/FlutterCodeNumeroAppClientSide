import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'core_providers.dart';
import '../../features/postLogin/users/user_barrel.dart';
import 'user_profile_state_provider.dart';

/// Provides the authentication service
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final rbacService = ref.watch(rbacServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final errorHandler = ref.watch(errorHandlerProvider);

  return AuthService(
    client,
    rbacService,
    connectivityService,
    errorHandler,
    ref,
  );
});

/// Stream of authentication state changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Listenable to trigger GoRouter redirects on auth changes
final authRefreshListenableProvider = Provider<Listenable>((ref) {
  final authState = ref.watch(authStateProvider);
  return ValueNotifier(authState);
});

/// Stream of the current user's profile
final userProfileProvider = StreamProvider<ModelUser?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  
  // Watch auth state changes; initial loading state is expected and handled
  final authAsync = ref.watch(authStateProvider);
  final user = authAsync.value?.session?.user ?? client.auth.currentUser;
  
  if (user == null) return Stream.value(null);

  return client
      .from(ModelUserFields.table)
      .stream(primaryKey: [ModelUserFields.userId])
      .eq(ModelUserFields.userId, user.id)
      .handleError((error, stackTrace) {
        ref
            .read(loggerServiceProvider)
            .error(
              'Error in userProfileProvider stream: $error',
              stackTrace is StackTrace ? stackTrace : null,
            );
      })
      .map((snapshot) {
        if (snapshot.isEmpty) return null;
        return ModelUser.fromMap(snapshot.first);
      });
});

/// Provider for the enriched user profile (with labels)
final enrichedUserProfileProvider = FutureProvider<ModelUser?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userProfile = ref.watch(userProfileProvider).value;

  if (userProfile == null) return null;

  final enriched = await client
      .from(ModelUserFields.tableViewWithForeignKeyLabels)
      .select()
      .eq(ModelUserFields.userId, userProfile.userId)
      .single();

  final updatedProfile = ModelUser.fromMap(enriched);
  // Optional: keep userProfileStateProvider in sync for legacy code
  ref.read(userProfileStateProvider.notifier).setProfile(updatedProfile);
  return updatedProfile;
});

/// Provider to extract the user's avatar URL from Supabase Auth metadata
final userAvatarUrlProvider = Provider<String?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;

  final metadata = user.userMetadata;
  final avatarUrl = metadata?['avatar_url'] as String?;
  if (avatarUrl == null || avatarUrl.isEmpty) return null;

  final uri = Uri.tryParse(avatarUrl);
  final host = uri?.host.toLowerCase() ?? '';

  // Google-hosted avatar URLs can start returning 429s in-app.
  // Prefer the initials fallback instead of repeatedly requesting them.
  if (host.contains('googleusercontent.com')) {
    return null;
  }

  return avatarUrl;
});
