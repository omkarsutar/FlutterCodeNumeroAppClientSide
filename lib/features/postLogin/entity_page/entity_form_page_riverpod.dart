import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/field_config.dart';
import '../../../core/models/entity_meta.dart';
import '../../../core/services/entity_service.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../core/providers/core_providers.dart';
import 'providers/generic_form_controller.dart';
import 'widgets/form_fields.dart';

/// Generic Riverpod version of Entity Form Page
/// Can be used for any entity type (Role, Note, etc.)
class EntityFormPageRiverpod<T> extends ConsumerStatefulWidget {
  final String? entityId;
  final EntityMeta entityMeta;
  final List<FieldConfig> fieldConfigs;
  final String listRouteName;
  final String rbacModule;

  // Riverpod providers
  final AutoDisposeFutureProviderFamily<T?, String> entityByIdProvider;
  final Provider<EntityAdapter<T>> adapterProvider;

  // Callbacks for entity-specific operations
  final Future<bool> Function(
    WidgetRef ref,
    Map<String, dynamic> fieldValues,
    String? entityId,
  )
  onSave;
  final Map<String, dynamic> Function(T entity)? initialValues;
  final Map<String, dynamic>? defaultValues;

  const EntityFormPageRiverpod({
    super.key,
    this.entityId,
    required this.entityMeta,
    required this.fieldConfigs,
    required this.listRouteName,
    required this.rbacModule,
    required this.entityByIdProvider,
    required this.adapterProvider,
    required this.onSave,
    this.initialValues,
    this.defaultValues,
  });

  @override
  ConsumerState<EntityFormPageRiverpod<T>> createState() =>
      _EntityFormPageRiverpodState<T>();
}

class _EntityFormPageRiverpodState<T>
    extends ConsumerState<EntityFormPageRiverpod<T>> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _switchValues = {};
  final Map<String, dynamic> _dropdownValues = {}; // Store selected IDs
  final Map<String, String> _selectorLabels =
      {}; // Store display labels for selectors

  // Track if we have initialized form data from remote entity
  bool _isDataLoaded = false;

  FocusNode? _firstFocusNode;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // Defer controller calls until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(
        genericFormControllerProvider(widget.entityMeta.entityName).notifier,
      );

      // Load Options
      controller.loadDropdownOptions(widget.fieldConfigs);

      // Load Entity if editing
      if (widget.entityId != null) {
        controller.loadEntity(
          entityId: widget.entityId!,
          entityByIdProvider: widget.entityByIdProvider,
          adapterProvider: widget.adapterProvider,
          fieldConfigs: widget.fieldConfigs,
          initialValuesMapper: widget.initialValues,
        );
      }
    });
  }

  void _initializeControllers() {
    for (var field in widget.fieldConfigs) {
      // Only initialize controllers for fields visible in form
      if (!field.visibleInForm) continue;

      final defaultValue = widget.defaultValues?[field.name];

      if (field.type == FieldType.switchField) {
        _switchValues[field.name] = (defaultValue as bool?) ?? false;
      } else if (field.type == FieldType.dropdown) {
        if (defaultValue != null) {
          _dropdownValues[field.name] = defaultValue.toString();
        } else if (field.dropdownOptions != null &&
            field.dropdownOptions!.isNotEmpty) {
          _dropdownValues[field.name] = field.dropdownOptions!.first;
        }
        // Dropdown doesn't use TextEditingController in this implementation
      } else if (field.type == FieldType.selector) {
        if (defaultValue != null) {
          _dropdownValues[field.name] = defaultValue.toString();
          // We might not have the label yet if it's just a default ID
          _selectorLabels[field.name] = defaultValue.toString();
        }
      } else {
        _controllers[field.name] = TextEditingController(
          text: defaultValue?.toString(),
        );
      }
    }
    // Set first text field focus node
    if (_controllers.isNotEmpty) {
      _firstFocusNode = FocusNode();
    }
  }

  void _populateForm(Map<String, dynamic> values) {
    if (_isDataLoaded) return;

    for (var field in widget.fieldConfigs) {
      if (!field.visibleInForm) continue;

      final value = values[field.name];

      if (field.type == FieldType.switchField) {
        if (value != null) setState(() => _switchValues[field.name] = value);
      } else if (field.type == FieldType.dropdown ||
          field.type == FieldType.selector) {
        if (value != null) {
          setState(() {
            _dropdownValues[field.name] = value.toString();

            // Use the label provided in the map if available
            final label = values['${field.name}_label'];
            if (label != null) {
              _selectorLabels[field.name] = label.toString();
            } else {
              _selectorLabels[field.name] = value.toString();
            }
          });
        }
      } else if (value != null) {
        _controllers[field.name]?.text = value.toString();
      }
    }

    setState(() => _isDataLoaded = true);
  }

  Future<void> _onSavePressed(GenericFormController controller) async {
    if (!_formKey.currentState!.validate()) return;

    // Collect field values
    final fieldValues = <String, dynamic>{};
    for (var field in widget.fieldConfigs) {
      if (field.type == FieldType.switchField) {
        fieldValues[field.name] = _switchValues[field.name] ?? false;
      } else if (field.type == FieldType.dropdown ||
          field.type == FieldType.selector) {
        fieldValues[field.name] = _dropdownValues[field.name];
      } else {
        fieldValues[field.name] = _controllers[field.name]?.text;
      }
    }

    controller.saveEntity(
      onSave: widget.onSave,
      fieldValues: fieldValues,
      entityId: widget.entityId,
      ref: ref,
    );
  }

  /// Build form fields list, filtering by visibility and tracking first field
  List<Widget> _buildFormFields(
    Map<String, List<Map<String, dynamic>>> dropdownOptions,
  ) {
    final visibleFields = widget.fieldConfigs
        .where((field) => field.visibleInForm)
        .toList();

    if (visibleFields.isEmpty) {
      return [const SizedBox.shrink()];
    }

    final widgets = <Widget>[];
    for (int i = 0; i < visibleFields.length; i++) {
      widgets.add(
        _buildField(visibleFields[i], dropdownOptions, isFirst: i == 0),
      );
      widgets.add(const SizedBox(height: 16));
    }
    return widgets;
  }

  Widget _buildField(
    FieldConfig field,
    Map<String, List<Map<String, dynamic>>> dropdownOptions, {
    bool isFirst = false,
  }) {
    switch (field.type) {
      case FieldType.switchField:
        return EntitySwitchField(
          field: field,
          value: _switchValues[field.name] ?? false,
          onChanged: (value) =>
              setState(() => _switchValues[field.name] = value),
        );
      case FieldType.dropdown:
        return EntityDropdownField(
          field: field,
          currentValue: _dropdownValues[field.name],
          options: dropdownOptions[field.name] ?? [],
          onChanged: (value) {
            if (value != null) {
              setState(() => _dropdownValues[field.name] = value);
            }
          },
        );
      case FieldType.selector:
        return EntitySelectorField(
          field: field,
          currentValue: _dropdownValues[field.name],
          currentLabel: _selectorLabels[field.name] ?? 'Select ${field.label}',
          onSelected: (id, label) {
            setState(() {
              _dropdownValues[field.name] = id;
              _selectorLabels[field.name] = label;
            });
          },
        );
      case FieldType.textarea:
        return EntityTextAreaField(
          field: field,
          controller: _controllers[field.name],
          focusNode: isFirst ? _firstFocusNode : null,
          isFirst: isFirst,
        );
      case FieldType.text:
      default:
        return EntityTextField(
          field: field,
          controller: _controllers[field.name],
          focusNode: isFirst ? _firstFocusNode : null,
          isFirst: isFirst,
        );
    }
  }

  @override
  void dispose() {
    _firstFocusNode?.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.entityId != null;

    // Controller
    final controllerKey = widget.entityMeta.entityName;
    final formState = ref.watch(genericFormControllerProvider(controllerKey));
    final controller = ref.read(
      genericFormControllerProvider(controllerKey).notifier,
    );

    // Initial Data Listener
    ref.listen<GenericFormState>(genericFormControllerProvider(controllerKey), (
      prev,
      next,
    ) {
      if (next.initialData != null && !_isDataLoaded) {
        _populateForm(next.initialData!);
      }

      if (next.isSuccess && !next.isLoading) {
        SnackbarUtils.showSuccess(
          '${widget.entityMeta.entityName} saved successfully!',
        );
        context.goNamed(widget.listRouteName);
      } else if (next.error != null && !next.isLoading) {
        ref
            .read(errorHandlerProvider)
            .handle(
              Exception(next.error),
              StackTrace.current,
              context: 'Saving ${widget.entityMeta.entityName}',
              showToUser: true,
            );
      }
    });

    final isInitialized = ref.watch(rbacInitializationProvider);
    final rbacService = ref.watch(rbacServiceProvider);

    if (!isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasPermission = isEditMode
        ? rbacService.canUpdate(widget.rbacModule)
        : rbacService.canCreate(widget.rbacModule);

    if (!hasPermission) {
      return Scaffold(
        appBar: CustomAppBar(
          title: isEditMode
              ? 'Edit ${widget.entityMeta.entityName}'
              : 'Add ${widget.entityMeta.entityName}',
          showBack: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'You do not have permission to ${isEditMode ? 'edit' : 'create'} ${widget.entityMeta.entityNamePluralLower}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditMode
            ? 'Edit ${widget.entityMeta.entityName}'
            : 'Add ${widget.entityMeta.entityName}',
        showBack: true,
      ),
      body: formState.isLoading && !_isDataLoaded && isEditMode
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Generate fields dynamically
                          ..._buildFormFields(formState.dropdownOptions),

                          const SizedBox(height: 8),
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  if (context.mounted && context.canPop()) {
                                    context.pop();
                                  }
                                },
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Cancel'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFE53935),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () => _onSavePressed(controller),
                                icon: const Icon(Icons.save),
                                label: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (formState.isLoading && _isDataLoaded)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
    );
  }
}
