import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/app_localization_provider.dart';

class AppErrorView extends ConsumerWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const AppErrorView({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  bool get _isConnectivityError {
    final errorText = error.toString();
    return errorText.contains('RealtimeSubscribeException') ||
        errorText.contains('WebSocket connection failed') ||
        errorText.contains('channelError') ||
        errorText.contains('NoInternetException') ||
        errorText.contains('SocketException');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appL10nProvider);
    final isOffline = _isConnectivityError;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isOffline ? Colors.orange : theme.colorScheme.error)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                size: 64,
                color: isOffline ? Colors.orange.shade700 : theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isOffline
                  ? (l10n['no_internet'] ?? 'Connection Issue')
                  : (l10n['error_loading'] ?? 'Something went wrong'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isOffline
                  ? (l10n['internet_disconnected'] ??
                      'You are offline. Some features may not work.')
                  : 'We encountered an error while loading the content: $error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SmallErrorView extends ConsumerWidget {
  final Object error;
  final VoidCallback? onRetry;
  final String? message;

  const SmallErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final errorText = error.toString();
    final isOffline = errorText.contains('RealtimeSubscribeException') ||
        errorText.contains('WebSocket connection failed') ||
        errorText.contains('channelError') ||
        errorText.contains('NoInternetException') ||
        errorText.contains('SocketException');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
            size: 20,
            color: isOffline ? Colors.orange : theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ?? (isOffline ? 'Offline' : 'Error loading content'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (onRetry != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 20),
              onPressed: onRetry,
              color: theme.colorScheme.primary,
              tooltip: 'Try Again',
            ),
        ],
      ),
    );
  }
}
