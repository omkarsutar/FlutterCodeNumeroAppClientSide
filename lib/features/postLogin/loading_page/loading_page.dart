import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/user_profile_state_provider.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/core_providers.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class LoadingPage extends ConsumerWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch both profile and RBAC initialization
    final profile = ref.watch(userProfileStateProvider).profile;
    final isRbacInitialized = ref.watch(rbacInitializationProvider);
    final rbacService = ref.read(rbacServiceProvider);
    final roleName = rbacService.roleName?.toLowerCase();
    final isGuest = roleName == 'guest';

    // If both are ready, proceed to redirect
    // Guests don't need preferredRouteId
    if (isRbacInitialized && (isGuest || profile?.preferredRouteId != null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.goNamed(AppRoute.cartName);
      });
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
