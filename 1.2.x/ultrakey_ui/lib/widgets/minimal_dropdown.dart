import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/utils.dart';
import 'package:ultrakey_ui/theme.dart';

class MinimalDropdown extends StatefulWidget {
  const MinimalDropdown({
    required this.items,
    this.initialValue,
    this.onChanged,
    this.expanded,
    super.key,
  });

  final List<String> items;
  final String? initialValue;
  final bool? expanded;
  final void Function(String)? onChanged;

  @override
  State<MinimalDropdown> createState() => _MinimalDropdownState();
}

class _MinimalDropdownState extends State<MinimalDropdown> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 1.2 * WidgetRatios.horizontalPadding),
      height: WidgetRatios.defaultIconSize,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(huge),
      ),
      child: DropdownButtonHideUnderline(
          child: Theme(
        data: Theme.of(context).copyWith(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: DropdownButton<String>(
          value: widget.initialValue ??
              (widget.items.isNotEmpty ? widget.items[0] : null),
          isExpanded: widget.expanded ?? false,
          icon: const Icon(Icons.arrow_drop_down),
          style: TextStyle(color: textColor),
          dropdownColor: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          items: widget.items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Center(
                child: Text(
                  item,
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            widget.onChanged?.call(value!);
          },
        ),
      )),
    );
  }
}
