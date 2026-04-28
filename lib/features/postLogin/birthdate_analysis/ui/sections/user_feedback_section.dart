import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/providers/auth_providers.dart';
import '../../../../../core/providers/birthdate_localization_provider.dart';
import '../utils/analysis_theme.dart';
import '../widgets/mystic_widgets.dart';

class UserFeedbackSection extends ConsumerStatefulWidget {
  const UserFeedbackSection({super.key});

  @override
  ConsumerState<UserFeedbackSection> createState() => _UserFeedbackSectionState();
}

class _UserFeedbackSectionState extends ConsumerState<UserFeedbackSection> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await ref.read(authServiceProvider).updateUserFeedback(feedback);
      if (mounted) {
        _feedbackController.clear();
        final l10n = ref.read(birthdateL10nProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n['feedback_success'] ?? 'Thank you for your feedback!'),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = ref.read(birthdateL10nProvider);
        setState(() {
          _errorText = l10n['feedback_error'] ?? 'Failed to send feedback. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider).value;
    
    // Only show if feedback is active for this user
    if (userProfile == null || !userProfile.isUserFeedbackActive) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = ref.watch(birthdateL10nProvider);
    final accent = AnalysisTheme.getAccent(theme);

    return MysticSection(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MysticHeader(
            title: l10n['feedback_title'] ?? 'Help us improve',
            icon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: 16),
          Text(
            l10n['feedback_hint'] ?? 'Tell us about your overall app experience...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accent.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _feedbackController,
              maxLines: 4,
              maxLength: 500,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(20),
                border: InputBorder.none,
                counterStyle: TextStyle(
                  color: accent.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'Share your thoughts...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              onChanged: (_) => setState(() => _errorText = null),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n['feedback_submit'] ?? 'Send Feedback',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
