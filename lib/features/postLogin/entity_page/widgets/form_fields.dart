import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/field_config.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../providers/entity_form_logic.dart';

class EntityTextField extends StatelessWidget {
  final FieldConfig field;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isFirst;

  const EntityTextField({
    super.key,
    required this.field,
    this.controller,
    this.focusNode,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: isFirst ? focusNode : null,
      autofocus: isFirst && !field.readOnly,
      enabled: !field.readOnly,
      maxLength: field.maxLength,
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(),
        counterText: '',
        helperText: field.readOnly ? 'Read-only' : null,
      ),
      validator: EntityFormLogic.buildValidator(field),
    );
  }
}

class EntityTextAreaField extends StatelessWidget {
  final FieldConfig field;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isFirst;

  const EntityTextAreaField({
    super.key,
    required this.field,
    this.controller,
    this.focusNode,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: isFirst ? focusNode : null,
      autofocus: isFirst && !field.readOnly,
      enabled: !field.readOnly,
      maxLines: 5,
      maxLength: field.maxLength,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(),
        counterText: '',
        helperText: field.readOnly ? 'Read-only' : null,
      ),
      validator: EntityFormLogic.buildValidator(field),
    );
  }
}

class EntitySwitchField extends StatelessWidget {
  final FieldConfig field;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const EntitySwitchField({
    super.key,
    required this.field,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.label, style: Theme.of(context).textTheme.titleMedium),
              if (field.readOnly)
                Text('Read-only', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        Switch(value: value, onChanged: field.readOnly ? null : onChanged),
      ],
    );
  }
}

class EntitySelectorField extends StatelessWidget {
  final FieldConfig field;
  final String? currentValue;
  final String currentLabel;
  final Function(String id, String label) onSelected;

  const EntitySelectorField({
    super.key,
    required this.field,
    this.currentValue,
    required this.currentLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormField<String>(
      initialValue: currentValue,
      validator: (value) =>
          EntityFormLogic.buildValidator(field)?.call(currentValue),
      builder: (FormFieldState<String> state) {
        return InkWell(
          onTap: field.readOnly
              ? null
              : () async {
                  final routeName = field.dropdownSource?.routeName;
                  if (routeName == null) {
                    SnackbarUtils.showError(
                      'No routeName defined for selector',
                    );
                    return;
                  }

                  final result = await context.pushNamed(
                    routeName,
                    queryParameters: {'selection': 'true'},
                  );

                  if (result != null) {
                    final valueKey = field.dropdownSource?.valueKey ?? 'id';
                    final labelKey = field.dropdownSource?.labelKey ?? 'name';

                    String? selectedId;
                    String? selectedLabel;

                    try {
                      if (result is Map) {
                        selectedId = result[valueKey]?.toString();
                        selectedLabel = result[labelKey]?.toString();
                      } else {
                        final map = (result as dynamic).toMap();
                        selectedId = map[valueKey]?.toString();
                        selectedLabel = map[labelKey]?.toString();
                      }
                    } catch (e) {
                      selectedId = result.toString();
                      selectedLabel = result.toString();
                    }

                    if (selectedId != null) {
                      onSelected(selectedId, selectedLabel ?? selectedId);
                      state.didChange(selectedId);
                    }
                  }
                },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
              errorText: state.errorText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              suffixIcon: const Icon(Icons.search),
              helperText: field.readOnly ? 'Read-only' : null,
            ),
            child: Text(
              currentLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: currentValue == null
                    ? theme.hintColor
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

class EntityDropdownField extends StatelessWidget {
  final FieldConfig field;
  final String? currentValue;
  final List<Map<String, dynamic>> options;
  final ValueChanged<String?> onChanged;

  const EntityDropdownField({
    super.key,
    required this.field,
    this.currentValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Handle static dropdown options
    if (field.dropdownOptions != null) {
      final items = field.dropdownOptions!.map((option) {
        return DropdownMenuItem<String>(value: option, child: Text(option));
      }).toList();

      return DropdownButtonFormField<String>(
        initialValue: currentValue ?? items.firstOrNull?.value,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
        ),
        items: items,
        onChanged: field.readOnly ? null : onChanged,
        validator: EntityFormLogic.buildValidator(field),
      );
    }

    // Dynamic Options
    if (currentValue != null && options.isEmpty) {
      return TextFormField(
        initialValue: currentValue,
        enabled: false,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
          helperText: 'Loading options...',
        ),
      );
    }

    final valueKey = field.dropdownSource?.valueKey ?? 'id';
    final labelKey = field.dropdownSource?.labelKey ?? 'name';

    final items = options.map<DropdownMenuItem<String>>((opt) {
      final value = opt[valueKey]?.toString() ?? '';
      final label = opt[labelKey]?.toString() ?? 'Unnamed';
      return DropdownMenuItem<String>(value: value, child: Text(label));
    }).toList();

    String? safeCurrentValue = currentValue;
    if (safeCurrentValue != null && items.isNotEmpty) {
      final valueExists = items.any((item) => item.value == safeCurrentValue);
      if (!valueExists) {
        safeCurrentValue = null;
      }
    }

    return DropdownButtonFormField<String>(
      initialValue: safeCurrentValue,
      decoration: InputDecoration(
        labelText: field.label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        helperText: field.readOnly ? 'Read-only' : null,
      ),
      items: items,
      onChanged: field.readOnly ? null : onChanged,
      validator: EntityFormLogic.buildValidator(field),
      isExpanded: true,
    );
  }
}
