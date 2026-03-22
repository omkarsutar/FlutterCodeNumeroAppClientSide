import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_supabase_order_app_mobile/core/providers/localization_provider.dart';
import 'package:flutter_supabase_order_app_mobile/core/utils/date_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_supabase_order_app_mobile/router/app_routes.dart';

import '../../../../core/services/entity_service.dart';
import '../../cart/providers/cart_providers.dart';
import '../model/purchase_order_model.dart';
import '../providers/purchase_order_tile_logic.dart';

class PurchaseOrderListTile extends ConsumerStatefulWidget {
  final ModelPurchaseOrder entity;
  final EntityAdapter<ModelPurchaseOrder> adapter;
  final VoidCallback? onTap;
  final bool? poItemTile;
  final bool showShare;
  final void Function(String oldStatus, String newStatus)? onStatusChanged;

  const PurchaseOrderListTile({
    super.key,
    required this.entity,
    required this.adapter,
    this.onTap,
    this.poItemTile,
    this.showShare = false,
    this.onStatusChanged,
  });

  @override
  ConsumerState<PurchaseOrderListTile> createState() =>
      _PurchaseOrderListTileState();
}

class _PurchaseOrderListTileState extends ConsumerState<PurchaseOrderListTile> {
  bool _isUpdating = false;

  void _onStatusChanged(String? newStatus) {
    if (newStatus == null) return;
    PurchaseOrderTileLogic.updateStatus(
      context: context,
      ref: ref,
      entity: widget.entity,
      newStatus: newStatus,
      setUpdating: (val) => setState(() => _isUpdating = val),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

    final dateStr = widget.entity.createdAt != null
        ? formatTimestamp(widget.entity.createdAt!)
        : '';
    final userComment = widget.entity.userComment ?? 'No Birthdate';
    final status = widget.entity.status ?? 'pending';
    final statusColor = PurchaseOrderTileLogic.getStatusColor(status);
    final birthdateLabel = l10n['birthdate_label'] ?? 'Birthdate';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          final userComment = widget.entity.userComment;
          if (userComment != null && userComment != 'No Birthdate') {
            try {
              final birthdate = DateFormat('dd-MMM-yyyy').parse(userComment);
              ref.read(birthdateProvider.notifier).state = birthdate;
            } catch (e) {
              debugPrint('Error parsing birthdate from history: $e');
            }
          }
          context.goNamed(AppRoute.cartName);
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Row(
            children: [
              // Mystical Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userComment,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$birthdateLabel • $dateStr",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusBadge(status: status, statusColor: statusColor),
                  if (status.toLowerCase() == 'confirmed' && widget.entity.poId != null) ...[
                    const SizedBox(height: 4),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      tooltip: 'Delete Order',
                      onPressed: () => PurchaseOrderTileLogic.deleteOrder(
                        context: context,
                        ref: ref,
                        poId: widget.entity.poId!,
                        setUpdating: (val) => setState(() => _isUpdating = val),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color statusColor;

  const _StatusBadge({required this.status, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

