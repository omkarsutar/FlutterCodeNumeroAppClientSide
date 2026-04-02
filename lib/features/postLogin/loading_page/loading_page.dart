import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/core_providers.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_routes.dart';
import 'package:go_router/go_router.dart';

class LoadingPage extends ConsumerWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch RBAC initialization
    final isRbacInitialized = ref.watch(rbacInitializationProvider);

    // If RBAC is initialized, we can proceed.
    if (isRbacInitialized) {
      debugPrint(
        '[LoadingPage] RBAC Initialized. Navigating to birthdateAnalysis...',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.goNamed(AppRoute.birthdateAnalysisName);
      });
    } else {
      debugPrint('[LoadingPage] Still waiting for RBAC initialization');
    }

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
