import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/field_config.dart';
import '../../../core/services/entity_service.dart';
import '../../../core/models/entity_meta.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/snackbar_utils.dart';
import 'providers/entity_view_logic.dart';
import 'providers/generic_view_controller.dart';
import '../../../shared/widgets/shared_widget_barrel.dart';
import '../../../core/providers/app_localization_provider.dart';

/// Generic Riverpod version of Entity View Page
/// Can be used for any entity type (Role, Note, etc.)
class EntityViewPageRiverpod<T> extends ConsumerWidget {
  final String entityId;
  final EntityMeta entityMeta;
  final List<FieldConfig> fieldConfigs;
  final String idField;
  final String? timestampField;
  final String editRouteName;
  final String rbacModule;

  // Riverpod providers
  final AutoDisposeFutureProviderFamily<T?, String> entityByIdProvider;
  final Provider<EntityAdapter<T>> adapterProvider;

  // Delete function from form provider - receives WidgetRef and entity ID
  final Future<bool> Function(WidgetRef ref, String id) deleteFunction;

  const EntityViewPageRiverpod({
    super.key,
    required this.entityId,
    required this.entityMeta,
    required this.fieldConfigs,
    required this.idField,
    this.timestampField,
    required this.editRouteName,
    required this.rbacModule,
    required this.entityByIdProvider,
    required this.adapterProvider,
    required this.deleteFunction,
  });

  Future<void> _onDeletePressed(
    BuildContext context,
    WidgetRef ref,
    GenericViewController controller,
  ) async {
    final l10n = ref.read(appL10nProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text((l10n['delete_entity_title'] ?? 'Delete {entity}')
            .replaceAll('{entity}', entityMeta.entityName)),
        content: Text((l10n['delete_entity_msg'] ??
                'Are you sure you want to delete this {entity}?')
            .replaceAll('{entity}', entityMeta.entityNameLower)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n['cancel'] ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n['delete_all'] ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await controller.deleteEntity(
        deleteFunction: deleteFunction,
        entityId: entityId,
        ref: ref,
      );
    }
  }

  Widget _buildFieldCard(
    BuildContext context,
    ThemeData theme,
    ProcessedEntityField processedField,
    Map<String, String> l10n,
  ) {
    if (processedField.rawValue == null ||
        processedField.rawValue.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field label
          Text(
            processedField.label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          // Field value
          if (processedField.type == EntityViewFieldType.phone)
            InkWell(
              onTap: () =>
                  EntityViewLogic.launchPhone(processedField.displayValue),
              child: Row(
                children: [
                  Icon(Icons.phone, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    processedField.displayValue,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                      decoration: TextDecoration.underline,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          else if (processedField.type == EntityViewFieldType.location)
            InkWell(
              onTap: () => EntityViewLogic.launchUrlExternally(
                processedField.actionUrl ?? '',
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n['open_in_maps'] ?? 'Open in Maps',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (processedField.type == EntityViewFieldType.switchField)
            Row(
              children: [
                Icon(
                  processedField.rawValue == true
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: processedField.rawValue == true
                      ? Colors.green
                      : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  processedField.displayValue,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            )
          else
            Text(
              processedField.displayValue,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoHeader(
    BuildContext context,
    ThemeData theme,
    String photoUrl,
    String title,
  ) {
    return InkWell(
      onTap: () => _showFullScreenImage(context, photoUrl, title),
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.broken_image,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    String photoUrl,
    String title,
  ) {
    // Dismiss keyboard/focus before opening dialog to avoid layout calculation issues on Web
    FocusManager.instance.primaryFocus?.unfocus();

    showDialog(
      context: context,
      builder: (context) {
        // Use a local TransformationController for double-tap support
        final transformationController = TransformationController();

        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Scaffold(
            backgroundColor: Colors.black,
            // Critical for Web/PWA: prevent keyboard resize logic from hitting negative ViewInsets assertions
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Center(
                  child: GestureDetector(
                    onDoubleTap: () {
                      if (transformationController.value !=
                          Matrix4.identity()) {
                        transformationController.value = Matrix4.identity();
                      } else {
                        // Zoom in to 2.5x on double tap
                        transformationController.value =
                            Matrix4.diagonal3Values(2.5, 2.5, 1.0);
                      }
                    },
                    child: InteractiveViewer(
                      transformationController: transformationController,
                      minScale: 0.5,
                      maxScale: 10.0,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      child: Image.network(
                        photoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(appL10nProvider);
    final entityAsync = ref.watch(entityByIdProvider(entityId));
    final entityAdapter = ref.watch(adapterProvider);
    final isInitialized = ref.watch(rbacInitializationProvider);
    final rbacService = ref.watch(rbacServiceProvider);

    // Check permissions
    final canUpdate = isInitialized && rbacService.canUpdate(rbacModule);
    final canDelete = isInitialized && rbacService.canDelete(rbacModule);

    // Controller
    final controllerKey = '${entityMeta.entityName}_view';
    final viewState = ref.watch(genericViewControllerProvider(controllerKey));
    final controller = ref.read(
      genericViewControllerProvider(controllerKey).notifier,
    );

    // Side Effects Listener
    ref.listen<GenericViewState>(genericViewControllerProvider(controllerKey), (
      previous,
      next,
    ) {
      if (next.isDeleted && !next.isLoading) {
        SnackbarUtils.showSuccess(
          '${entityMeta.entityName} ${l10n['delete_success_msg'] ?? 'deleted successfully!'}',
        );
        if (context.mounted && context.canPop()) {
          context.pop();
        }
      } else if (next.error != null && !next.isLoading) {
        SnackbarUtils.showError(
            '${l10n['delete_failed_msg'] ?? 'Failed to delete'}: ${next.error}');
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: (l10n['view_entity_title'] ?? 'View {entity}')
            .replaceAll('{entity}', entityMeta.entityName),
        showBack: true,
        actions: [
          // Edit button - only show if user has update permission
          if (canUpdate)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.pushNamed(
                  editRouteName,
                  pathParameters: {'id': entityId},
                );
              },
            ),
          // Delete button - only show if user has delete permission
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: viewState.isLoading
                  ? null
                  : () => _onDeletePressed(context, ref, controller),
            ),
        ],
      ),
      body: Stack(
        children: [
          entityAsync.when(
            data: (entity) {
              if (entity == null) {
                return Center(
                  child: Text((l10n['entity_not_found_msg'] ?? '{entity} not found')
                      .replaceAll('{entity}', entityMeta.entityName)),
                );
              }

              final timestampValue = timestampField != null
                  ? entityAdapter.getFieldValue(entity, timestampField!)
                  : null;
              String timestampStr = '';
              if (timestampValue != null) {
                timestampStr = EntityViewLogic.formatDateLikeField(
                  FieldConfig(name: 'timestamp', label: ''),
                  timestampValue,
                );
              }

              // Pre-process all fields
              final processedFields = fieldConfigs.map((field) {
                final fieldName = field.name;
                dynamic value;

                // For ID fields, try to get the label value first
                if (fieldName.endsWith('_id')) {
                  value =
                      entityAdapter.getLabelValue(entity, fieldName) ??
                      entityAdapter.getFieldValue(entity, fieldName);
                } else {
                  value = entityAdapter.getFieldValue(entity, fieldName);
                }

                return EntityViewLogic.processField(
                  field: field,
                  value: value,
                  adapter: entityAdapter,
                  entity: entity,
                );
              }).toList();

              // Find photo URL for header
              String? headerPhotoUrl;
              String? photoField;
              for (final pf in processedFields) {
                if (pf.type == EntityViewFieldType.photo &&
                    pf.actionUrl != null) {
                  headerPhotoUrl = Uri.encodeFull(
                    Uri.decodeFull(pf.actionUrl!),
                  );
                  photoField = pf.name;
                  break;
                }
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Header
                    if (headerPhotoUrl != null)
                      _buildPhotoHeader(
                        context,
                        theme,
                        headerPhotoUrl,
                        entityMeta.entityName,
                      ),

                    // Content with padding
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (timestampStr.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                timestampStr,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ),

                          // Field cards
                          ...processedFields
                              .where((f) => f.name != photoField)
                              .map((processedField) {
                                return _buildFieldCard(
                                  context,
                                  theme,
                                  processedField,
                                  l10n,
                                );
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => AppErrorView(
              error: err,
              stackTrace: stack,
              onRetry: () => ref.refresh(entityByIdProvider(entityId)),
            ),
          ),

          // Loading Overlay
          if (viewState.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
