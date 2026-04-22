import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers/app_localization_provider.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/providers/core_providers.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/analytics_service.dart';
import '../../core/utils/dialogs.dart';
import '../../router/app_routes.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  const CustomDrawer({super.key});

  @override
  ConsumerState<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  bool _hasImageError = false;

  String? _userDisplayName() {
    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.valueOrNull;
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      final name = currentUser?.userMetadata?['name']?.toString();
      if (name != null && name.isNotEmpty) return name;
      return currentUser?.email;
    }

    return user.fullName ?? currentUser?.email;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rbacInitializationProvider);

    final authService = ref.watch(authServiceProvider);
    final rbacService = ref.watch(rbacServiceProvider);
    final avatarUrl = ref.watch(userAvatarUrlProvider);
    final displayName = _userDisplayName();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = ref.watch(appL10nProvider);
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final isDark = theme.brightness == Brightness.dark;

    final initials = displayName != null && displayName.isNotEmpty
        ? displayName
              .trim()
              .split(' ')
              .take(2)
              .map((e) => e[0])
              .join()
              .toUpperCase()
        : '?';

    final drawerTextColor = colorScheme.onSurface;
    final drawerMutedTextColor = colorScheme.onSurfaceVariant;
    final drawerAccentColor = colorScheme.secondary;
    final drawerDividerColor = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.65 : 0.9,
    );
    final drawerTileColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.36)
        : colorScheme.primaryContainer.withValues(alpha: 0.42);
    final drawerShellGradient = isDark
        ? const [
            AppPalette.darkBackground,
            AppPalette.darkSurface,
            AppPalette.darkSurfaceRaised,
          ]
        : const [
            AppPalette.lightSurface,
            AppPalette.lightBackground,
            AppPalette.lightPrimaryContainer,
          ];
    final drawerHeaderGradient = isDark
        ? const [
            AppPalette.darkPrimaryContainer,
            AppPalette.darkSurfaceRaised,
            AppPalette.darkBackground,
          ]
        : const [
            AppPalette.logoBlue,
            Color(0xFF365DFF),
            AppPalette.lightPrimaryContainer,
          ];

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: drawerShellGradient,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: drawerHeaderGradient,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: drawerAccentColor.withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: drawerAccentColor.withValues(alpha: 0.12),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            width: 60,
                            height: 60,
                            color: colorScheme.primaryContainer,
                            child: avatarUrl != null && !_hasImageError
                                ? CachedNetworkImage(
                                    imageUrl: avatarUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          color: colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (mounted && !_hasImageError) {
                                              setState(
                                                () => _hasImageError = true,
                                              );
                                            }
                                          });
                                      return Center(
                                        child: Text(
                                          initials,
                                          style: TextStyle(
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        color: colorScheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: drawerAccentColor,
                            size: 20,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Numero Shastra',
                            style: TextStyle(
                              color: drawerTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName != null
                        ? (l10n['welcome_user'] ?? 'Welcome, {name}')
                              .replaceAll('{name}', displayName)
                        : l10n['welcome_numeroshastra'] ??
                              'Welcome to Numero Shastra',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: drawerTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (rbacService.roleName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${l10n['role'] ?? 'Role'}: ${rbacService.roleName!}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: drawerMutedTextColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _DrawerTile(
              icon: Icons.auto_awesome_rounded,
              title: l10n['birthdate_analysis'] ?? 'Birthdate Analysis',
              iconColor: drawerAccentColor,
              textColor: drawerTextColor,
              tileColor: drawerTileColor,
              onTap: () {
                ref
                    .read(analyticsServiceProvider)
                    .logClickEvent('drawer_analysis_clicked');
                Navigator.pop(context);
                context.goNamed(AppRoute.birthdateAnalysisName);
              },
            ),
            _DrawerTile(
              icon: Icons.shopping_cart,
              title: l10n['my_cart'] ?? 'My Cart',
              iconColor: drawerAccentColor,
              textColor: drawerTextColor,
              tileColor: drawerTileColor,
              onTap: () {
                ref
                    .read(analyticsServiceProvider)
                    .logClickEvent('drawer_cart_clicked');
                Navigator.pop(context);
                context.goNamed(AppRoute.cartName);
              },
            ),
            if (isLoggedIn)
              _DrawerTile(
                icon: Icons.receipt_long,
                title: l10n['purchase_history'] ?? 'Purchase History',
                iconColor: drawerAccentColor,
                textColor: drawerTextColor,
                tileColor: drawerTileColor,
                onTap: () {
                  ref
                      .read(analyticsServiceProvider)
                      .logClickEvent('drawer_history_clicked');
                  Navigator.pop(context);
                  context.goNamed(AppRoute.purchaseOrdersName);
                },
              ),
            if (isLoggedIn && rbacService.roleName?.toLowerCase() == 'admin')
              _DrawerTile(
                icon: Icons.notification_add_rounded,
                title: 'Send Notifications',
                iconColor: drawerAccentColor,
                textColor: drawerTextColor,
                tileColor: drawerTileColor,
                onTap: () {
                  ref
                      .read(analyticsServiceProvider)
                      .logClickEvent('drawer_notifications_admin_clicked');
                  Navigator.pop(context);
                  context.goNamed(AppRoute.notificationAdminName);
                },
              ),
            if (isLoggedIn)
              _DrawerTile(
                icon: Icons.person,
                title: l10n['profile'] ?? 'Profile',
                iconColor: drawerAccentColor,
                textColor: drawerTextColor,
                tileColor: drawerTileColor,
                onTap: () {
                  ref
                      .read(analyticsServiceProvider)
                      .logClickEvent('drawer_profile_clicked');
                  Navigator.pop(context);
                  context.goNamed(AppRoute.profileName);
                },
              ),
            if (!isLoggedIn)
              _DrawerTile(
                icon: Icons.login,
                title: l10n['login'] ?? 'Login',
                iconColor: drawerAccentColor,
                textColor: drawerTextColor,
                tileColor: drawerTileColor,
                onTap: () {
                  Navigator.pop(context);
                  context.goNamed(AppRoute.loginName);
                },
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Divider(color: drawerDividerColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                tileColor: drawerTileColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                secondary: Icon(
                  ref.watch(themeModeProvider) == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: drawerAccentColor,
                ),
                title: Text(
                  l10n['dark_mode'] ?? 'Dark Mode',
                  style: TextStyle(color: drawerTextColor),
                ),
                value: ref.watch(themeModeProvider) == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state = value
                      ? ThemeMode.dark
                      : ThemeMode.light;
                },
              ),
            ),
            if (Supabase.instance.client.auth.currentSession != null)
              _DrawerTile(
                icon: Icons.logout,
                title: l10n['logout'] ?? 'Logout',
                iconColor: drawerAccentColor,
                textColor: drawerTextColor,
                tileColor: drawerTileColor,
                onTap: () async {
                  final confirmed = await showConfirmationDialog(
                    context: context,
                    title: l10n['logout'] ?? 'Logout',
                    content: 'Are you sure you want to Logout?',
                    confirmLabel: l10n['logout'] ?? 'Logout',
                  );
                  if (confirmed) {
                    ref
                        .read(analyticsServiceProvider)
                        .logClickEvent('logout_confirmed');
                    await authService.signOut();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.textColor,
    required this.tileColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color iconColor;
  final Color textColor;
  final Color tileColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: tileColor,
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
      ),
    );
  }
}
