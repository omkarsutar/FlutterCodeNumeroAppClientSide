import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/providers/auth_providers.dart';
import '../../core/providers/core_providers.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../core/validators/form_validators.dart';
import 'shared_widget_barrel.dart';
import '../../features/postLogin/users/user_barrel.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildAvatar({
    required BuildContext context,
    required ThemeData theme,
    required String initials,
    required String? avatarUrl,
    required double size,
  }) {
    final avatar = avatarUrl;
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: theme.colorScheme.primaryContainer,
        child: avatar != null && avatar.isNotEmpty
            ? Image.network(
                avatar,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Text(
                      initials.toUpperCase(),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      initials.toUpperCase(),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  initials.toUpperCase(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _updateProfile(ModelUser profile) async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        ModelUserFields.fullName: _nameController.text,
      };

      if (!await ref.read(connectivityServiceProvider).isOnline()) {
        throw NoInternetException();
      }

      await Supabase.instance.client
          .from(ModelUserFields.table)
          .update(updatedData)
          .eq(ModelUserFields.userId, profile.userId);

      await ref.read(authServiceProvider).loadAndStoreUserProfile();
      SnackbarUtils.showSuccess('Profile updated!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(enrichedUserProfileProvider);
    final avatarUrl = ref.watch(userAvatarUrlProvider);
    final theme = Theme.of(context);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const Scaffold(body: Center(child: Text('No profile found')));
        }

        // Initialize controllers with profile data if empty
        if (_nameController.text.isEmpty && profile.fullName != null) {
          _nameController.text = profile.fullName!;
        }

        final fullName = profile.fullName ?? '';
        final email = profile.email ?? Supabase.instance.client.auth.currentUser?.email ?? '';
        final roleLabel = profile.resolvedLabels['role_id_label'] ??
            profile.roleId ??
            'Unknown Role';
        final initials = fullName.isNotEmpty
            ? fullName.trim().split(' ').take(2).map((e) => e[0]).join()
            : '?';

        return Scaffold(
          appBar: CustomAppBar(title: 'Your Profile', showBack: false),
          drawer: const CustomDrawer(),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar
                    _buildAvatar(
                      context: context,
                      theme: theme,
                      initials: initials,
                      avatarUrl: avatarUrl,
                      size: 100,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName.isNotEmpty ? fullName : 'No Name',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    if (email.isNotEmpty) ...[
                      Text(
                        email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      'Role: $roleLabel',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Form Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Personal Information',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                  ),
                                ),
                                validator: FormValidators.required(
                                  message: 'Enter your name',
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () => _updateProfile(profile),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, stack) => Scaffold(
        appBar: CustomAppBar(title: 'Your Profile', showBack: false),
        drawer: const CustomDrawer(),
        body: AppErrorView(
          error: e,
          stackTrace: stack,
          onRetry: () => ref.invalidate(enrichedUserProfileProvider),
        ),
      ),
    );
  }
}
