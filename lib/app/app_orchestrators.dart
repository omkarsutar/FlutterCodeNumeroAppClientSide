import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_supabase_order_app_mobile/core/globals.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/auth_providers.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/localization_provider.dart';
import 'package:flutter_supabase_order_app_mobile/core/services/connectivity_service.dart';
import 'package:flutter_supabase_order_app_mobile/features/postLogin/retailer_shop_links/retailer_shop_link_barrel.dart';
import 'package:flutter_supabase_order_app_mobile/features/postLogin/users/user_barrel.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_router.dart';

class AppOrchestratorScope extends StatelessWidget {
  final Widget child;

  const AppOrchestratorScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AuthBootstrapOrchestrator(
      child: ConnectivityToastOrchestrator(
        child: RoleChangeOrchestrator(
          child: RetailerShopLinkChangeOrchestrator(child: child),
        ),
      ),
    );
  }
}

class AuthBootstrapOrchestrator extends ConsumerStatefulWidget {
  final Widget child;

  const AuthBootstrapOrchestrator({super.key, required this.child});

  @override
  ConsumerState<AuthBootstrapOrchestrator> createState() =>
      _AuthBootstrapOrchestratorState();
}

class _AuthBootstrapOrchestratorState
    extends ConsumerState<AuthBootstrapOrchestrator> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authServiceProvider).initializeAuthListener();

      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        ref.read(authServiceProvider).loadAndStoreUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class RoleChangeOrchestrator extends ConsumerWidget {
  final Widget child;

  const RoleChangeOrchestrator({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<ModelUser?>>(userProfileProvider, (previous, next) {
      if (previous == null || previous.value == null || next.value == null) {
        return;
      }

      final oldRoleId = previous.value?.roleId;
      final newRoleId = next.value?.roleId;

      if (oldRoleId == null || newRoleId == null || oldRoleId == newRoleId) {
        return;
      }

      scaffoldMessengerKey.currentState?.clearSnackBars();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.security, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ref.watch(l10nProvider)['role_change_msg'] ??
                      'Your access permissions have changed. Reloading app...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () async {
        await ref.read(authServiceProvider).loadAndStoreUserProfile();
        ref.read(routerProvider).refresh();
      });
    });

    return child;
  }
}

class RetailerShopLinkChangeOrchestrator extends ConsumerWidget {
  final Widget child;

  const RetailerShopLinkChangeOrchestrator({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<ModelRetailerShopLink>>>(
      retailerShopLinksStreamProvider,
      (previous, next) {
        if (!next.hasValue || previous == null || !previous.hasValue) return;

        final previousLinks = previous.value!;
        final currentLinks = next.value!;
        if (!_hasLinkChanges(previousLinks, currentLinks)) return;

        scaffoldMessengerKey.currentState?.clearSnackBars();
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.link, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ref.watch(l10nProvider)['shop_link_change_msg'] ??
                        'Your shop assignments have changed. Reloading app...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade800,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () async {
          await ref.read(authServiceProvider).loadAndStoreUserProfile();
          ref.read(routerProvider).refresh();
        });
      },
    );

    return child;
  }

  bool _hasLinkChanges(
    List<ModelRetailerShopLink> previousLinks,
    List<ModelRetailerShopLink> currentLinks,
  ) {
    if (previousLinks.length != currentLinks.length) return true;

    final previousMap = {for (final link in previousLinks) link.linkId: link};
    final currentMap = {for (final link in currentLinks) link.linkId: link};

    for (final entry in previousMap.entries) {
      final currentLink = currentMap[entry.key];
      if (currentLink == null) return true;
      if (entry.value.userId != currentLink.userId ||
          entry.value.shopId != currentLink.shopId) {
        return true;
      }
    }

    return currentMap.keys.any((linkId) => !previousMap.containsKey(linkId));
  }
}

class ConnectivityToastOrchestrator extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityToastOrchestrator({super.key, required this.child});

  @override
  ConsumerState<ConnectivityToastOrchestrator> createState() =>
      _ConnectivityToastOrchestratorState();
}

class _ConnectivityToastOrchestratorState
    extends ConsumerState<ConnectivityToastOrchestrator> {
  bool? _previousStatus;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (previous, next) {
      final isOnline = next.valueOrNull;
      if (isOnline == null) return;

      if (_previousStatus == null) {
        _previousStatus = isOnline;
        return;
      }

      if (_previousStatus == isOnline) return;
      _previousStatus = isOnline;

      final l10n = ref.read(l10nProvider);

      scaffoldMessengerKey.currentState?.clearSnackBars();
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(isOnline ? Icons.wifi : Icons.wifi_off, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isOnline
                      ? (l10n['internet_connected'] ?? 'Back online!')
                      : (l10n['internet_disconnected'] ??
                          'You are offline. Some features may not work.'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor:
              isOnline ? Colors.green.shade700 : Colors.red.shade700,
          duration: Duration(seconds: isOnline ? 3 : 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });

    return widget.child;
  }
}
