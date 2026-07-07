import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/field_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/user_profile_state_provider.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/entity_service.dart';
import '../model/purchase_order_model.dart';

import '../../../../core/config/module_config.dart';
import '../../../../core/interfaces/connectivity_service_interface.dart';

class PurchaseOrderServiceImpl
    extends ForeignKeyAwareService<ModelPurchaseOrder> {
  final EntityMapper<ModelPurchaseOrder> _mapper;
  final Ref _ref;

  PurchaseOrderServiceImpl(
    this._mapper,
    SupabaseClient client,
    LoggerService logger,
    IConnectivityService connectivityService,
    this._ref, {
    SortingConfig? initialSorting,
  }) : super(client, logger, connectivityService) {
    if (initialSorting != null) {
      sortField = initialSorting.field;
      sortAscending = initialSorting.sortAscending;
    } else {
      /* sortField = ModelPurchaseOrderFields.createdAt;
      sortAscending = false; */
    }
  }

  @override
  EntityMapper<ModelPurchaseOrder> get mapper => _mapper;

  @override
  String get tableName => ModelPurchaseOrderFields.table;

  @override
  String get idColumn => ModelPurchaseOrderFields.poId;
  @override
  String get createdAt => ModelPurchaseOrderFields.createdAt;

  @override
  Map<String, ForeignKeyConfig> get foreignKeys => const {};

  // --- Custom helpers ---

  /// Create an empty purchase order for the current user.
  Future<Map<String, dynamic>> createEmptyPurchaseOrder({
    required List<String> birthdateIds,
  }) async {
    final userId = _ref.read(userProfileStateProvider).profile?.userId;
    if (userId == null) throw Exception('No signed-in user found');

    final entity = ModelPurchaseOrder(
      poTotalAmount: 0.0,
      poLineItemCount: 0,
      userComment: null,
      profitToShop: null,
      poLat: null,
      poLong: null,
      status: null,
      createdBy: userId,
      updatedBy: userId,
      birthdateIds: birthdateIds,
    );

    final enriched = mapper.toMap(entity);
    final response = await client
        .from(tableName)
        .insert(enriched)
        .select()
        .single();
    return response;
  }

  /// Fetch all purchase orders for a given shop
  /// Convenience method to get raw maps instead of typed entities.
  Future<List<Map<String, dynamic>>> getAllEntities() async {
    final response = await client
        .from(tableName)
        .select()
        .order(sortField ?? createdAt, ascending: sortAscending);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Stream<List<ModelPurchaseOrder>> streamEntities() {
    final controller = StreamController<List<ModelPurchaseOrder>>();
    RealtimeChannel? channel;

    Future<void> fetch() async {
      try {
        final userId = _ref.read(userProfileStateProvider).profile?.userId;
        var query = client.from(tableName).select();

        if (userId != null) {
          query = query.eq(ModelPurchaseOrderFields.createdBy, userId);
        }

        final List<dynamic> data = await query.order(
          sortField ?? createdAt,
          ascending: sortAscending,
        );

        if (!controller.isClosed) {
          controller.add(data.map((e) => mapper.fromMap(e)).toList());
        }
      } catch (e) {
        if (!controller.isClosed) controller.addError(e);
      }
    }

    void startSubscription() {
      fetch();
      channel = client.channel('public:$tableName')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: tableName,
          callback: (_) => fetch(),
        )
        ..subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.timedOut ||
              status == RealtimeSubscribeStatus.channelError) {
            logger.error(
              'Realtime subscription error for purchase_orders: $status ${error ?? ""}',
              null,
            );
            if (!controller.isClosed) {
              controller.addError('no_internet');
            }
          }
        });
    }

    controller.onListen = startSubscription;
    controller.onCancel = () => channel?.unsubscribe();

    return controller.stream;
  }

  @override
  Future<List<ModelPurchaseOrder>> fetchAll() async {
    final userId = _ref.read(userProfileStateProvider).profile?.userId;
    var query = client.from(tableName).select();

    if (userId != null) {
      query = query.eq(ModelPurchaseOrderFields.createdBy, userId);
    }

    final response = await query.order(
      sortField ?? createdAt,
      ascending: sortAscending,
    );
    return (response as List).map((e) => mapper.fromMap(e)).toList();
  }

  @override
  Future<ModelPurchaseOrder> fetchById(String id) async {
    final response = await client
        .from(tableName)
        .select()
        .eq(idColumn, id)
        .single();
    return mapper.fromMap(response);
  }

  // --- Override insertEntity to enrich with createdBy/updatedBy ---
  @override
  Future<void> insertEntity(ModelPurchaseOrder entity) async {
    final userId = _ref.read(userProfileStateProvider).profile?.userId;
    if (userId == null) throw Exception('No signed-in user found');

    final enriched = mapper.toMap(entity);
    enriched[ModelPurchaseOrderFields.createdBy] = userId;
    enriched[ModelPurchaseOrderFields.updatedBy] = userId;

    await client.from(tableName).insert(enriched);
  }
}
