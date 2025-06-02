import 'package:flutter/material.dart';
import 'package:launcher/models/utils.dart';
import 'package:launcher/theme.dart';

class MinimalDropdown<T> extends StatefulWidget {
  const MinimalDropdown({
    required this.items,
    this.initialValue,
    this.onChanged,
    this.expanded,
    this.displayText,
    super.key,
  });

  final List<T> items;
  final T? initialValue;
  final bool? expanded;
  final void Function(T?)? onChanged;
  final String Function(T)? displayText;

  @override
  State<MinimalDropdown> createState() => _MinimalDropdownState<T>();
}

class _MinimalDropdownState<T> extends State<MinimalDropdown<T>> {
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
        child: DropdownButton<T>(
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
                  widget.displayText?.call(item) ?? "NONE",
                  softWrap: false,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            widget.onChanged?.call(value);
          },
        ),
      )),
    );
  }
}
