import 'package:flutter/material.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/input_box.dart';

class InputCaptureGrid extends StatefulWidget {
  const InputCaptureGrid({
    required this.rows,
    required this.columns,
    this.checkEnabled,
    this.iconData = const {},
    this.idTable = const [],
    this.values,
    this.onChanged,
    super.key,
  });

  final int rows;
  final int columns;
  final List<List<String>>? values;
  final Map<String, Widget>? iconData;
  final List<String>? idTable;
  final void Function(String, dynamic)? onChanged;
  final bool Function(String, int)? checkEnabled;

  @override
  State<InputCaptureGrid> createState() => _InputCaptureGridState();
}

class _InputCaptureGridState extends State<InputCaptureGrid> {
  @override
  void initState() {
    super.initState();
  }

  String? _getId(int row, int col) {
    if (widget.idTable != null && row < (widget.idTable?.length ?? 0)) {
      return "${(widget.idTable?[row] ?? "UNKNOWN")}$col";
    }

    return null;
  }

  String _getDisplayName(int row, int col) {
    if (row < (widget.values?.length ?? -1) &&
        col < (widget.values?[row].length ?? -1)) {
      return widget.values?[row][col] ?? "";
    }

    return "";
  }

  void _updateValue(int row, int col, int event) {
    String? id = _getId(row, col);
    widget.onChanged?.call(id ?? "NONE", event);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetRatios.widgetPadding(scale: 0.5),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.rows, (row) {
              if (widget.iconData != null && row < widget.iconData!.length) {
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: widget.iconData![widget.idTable?[row] ?? 0]!,
                );
              }
              return Padding(
                padding: const EdgeInsets.all(4),
                child: Container(),
              );
            }),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.rows,
                (row) => Row(
                  children: List.generate(
                    widget.columns,
                    (col) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: InputCaptureBox(
                          displayText: _getDisplayName(row, col),
                          onChanged: (event) => _updateValue(row, col, event),
                          conflict: !(widget.checkEnabled?.call(
                                  widget.idTable?[row] ?? "UNKNOWN", col) ??
                              true),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
