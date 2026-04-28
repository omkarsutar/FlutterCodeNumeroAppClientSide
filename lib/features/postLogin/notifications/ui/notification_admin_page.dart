import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/shared_widget_barrel.dart';
import '../../../../core/providers/core_providers.dart';
import '../../users/user_barrel.dart';
import '../providers/notification_controller.dart';

class NotificationAdminPage extends ConsumerStatefulWidget {
  const NotificationAdminPage({super.key});

  @override
  ConsumerState<NotificationAdminPage> createState() =>
      _NotificationAdminPageState();
}

class _NotificationAdminPageState extends ConsumerState<NotificationAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _sendToAll = false;
  final List<String> _selectedUserIds = [];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_sendToAll && _selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one recipient')),
      );
      return;
    }

    final success = await ref
        .read(notificationControllerProvider.notifier)
        .sendNotification(
          userIds: _selectedUserIds,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          sendToAll: _sendToAll,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent successfully')),
        );
        _titleController.clear();
        _bodyController.clear();
        setState(() {
          _selectedUserIds.clear();
          _sendToAll = false;
        });
      } else {
        final error = ref.read(notificationControllerProvider).error;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationState = ref.watch(notificationControllerProvider);
    final isLoading = notificationState.isLoading;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Send Notifications'),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Broadcast',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Send a push notification to your users via FCM.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Recipient Section
              _buildSectionTitle(theme, 'Recipients'),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Send to all users'),
                subtitle: const Text(
                  'Broadcast message to every registered device',
                ),
                value: _sendToAll,
                onChanged: (val) => setState(() => _sendToAll = val),
                contentPadding: EdgeInsets.zero,
              ),

              if (!_sendToAll) ...[
                const SizedBox(height: 16),
                _buildUserSelector(theme),
              ],

              const SizedBox(height: 32),

              // Content Section
              _buildSectionTitle(theme, 'Message Content'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Notification Title',
                  hintText: 'e.g. New Feature Available!',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notification Body',
                  hintText: 'Type your message here...',
                  prefixIcon: Icon(Icons.message),
                  alignLabelWithHint: true,
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Body is required' : null,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _handleSend,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(isLoading ? 'Sending...' : 'Send Notification'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildUserSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select specific users:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(maxHeight: 250),
          child: StreamBuilder<List<ModelUser>>(
                  stream: ref
                      .watch(supabaseClientProvider)
                      .from(ModelUserFields.table)
                      .stream(primaryKey: [ModelUserFields.userId])
                      .map(
                        (list) =>
                            list.map((m) => ModelUser.fromMap(m)).toList(),
                      ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final users = snapshot.data ?? [];
                    if (users.isEmpty) {
                      return const Center(child: Text('No users found'));
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isSelected = _selectedUserIds.contains(
                          user.userId,
                        );

                        return CheckboxListTile(
                          title: Text(user.fullName ?? 'Unknown User'),
                          subtitle: Text(user.userId),
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedUserIds.add(user.userId);
                              } else {
                                _selectedUserIds.remove(user.userId);
                              }
                            });
                          },
                        );
                      },
                    );
                  },
                ),
        ),
        if (_selectedUserIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_selectedUserIds.length} users selected',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
