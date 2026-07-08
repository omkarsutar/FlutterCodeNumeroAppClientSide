import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_constants.dart';
import '../providers/core_providers.dart';
import '../services/native_update_service.dart';

class ForceUpdateGate extends ConsumerStatefulWidget {
  final Widget child;

  const ForceUpdateGate({super.key, required this.child});

  @override
  ConsumerState<ForceUpdateGate> createState() => _ForceUpdateGateState();
}

class _ForceUpdateGateState extends ConsumerState<ForceUpdateGate> {
  late final Future<PackageInfo> _packageInfoFuture;
  bool _attemptedImmediateUpdate = false;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !kReleaseMode || defaultTargetPlatform != TargetPlatform.android) {
      return widget.child;
    }

    final configAsync = ref.watch(appRemoteConfigProvider);

    return configAsync.when(
      loading: () => const _CheckingUpdateScreen(),
      error: (_, __) => widget.child,
      data: (config) {
        return FutureBuilder<PackageInfo>(
          future: _packageInfoFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const _CheckingUpdateScreen();

            final packageInfo = snapshot.data!;
            final currentVersionCode =
                int.tryParse(packageInfo.buildNumber.trim()) ?? 0;
            final requiredVersionCode = config.androidMinVersionCode;
            final shouldForceUpdate =
                config.forceUpdateAndroid &&
                requiredVersionCode > 0 &&
                currentVersionCode < requiredVersionCode;

            if (!shouldForceUpdate) return widget.child;

            _startImmediateUpdateOnce();

            final packageName = config.packageName.trim().isNotEmpty
                ? config.packageName.trim()
                : AppConstants.appPackageName;

            return _ForceUpdateRequiredScreen(
              packageName: packageName,
              currentVersionCode: currentVersionCode,
              requiredVersionCode: requiredVersionCode,
              latestVersionCode: config.androidLatestVersionCode,
            );
          },
        );
      },
    );
  }

  void _startImmediateUpdateOnce() {
    if (_attemptedImmediateUpdate) return;
    _attemptedImmediateUpdate = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NativeUpdateService.performImmediateUpdateIfAvailable();
      if (mounted) setState(() {});
    });
  }
}

class _CheckingUpdateScreen extends StatelessWidget {
  const _CheckingUpdateScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _ForceUpdateRequiredScreen extends StatelessWidget {
  final String packageName;
  final int currentVersionCode;
  final int requiredVersionCode;
  final int androidLatestVersionCode;

  const _ForceUpdateRequiredScreen({
    required this.packageName,
    required this.currentVersionCode,
    required this.requiredVersionCode,
    required int latestVersionCode,
  }) : androidLatestVersionCode = latestVersionCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestLabel = androidLatestVersionCode > 0
        ? 'Latest build: $androidLatestVersionCode'
        : 'A newer version is available';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.system_update_rounded,
                        color: theme.colorScheme.primary,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Update required',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please update Numero Shastra from Google Play to continue using the app.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$latestLabel - Current build: $currentVersionCode - Required build: $requiredVersionCode',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () =>
                            NativeUpdateService.openStoreListing(packageName),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Update from Google Play'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
