import 'package:flutter/material.dart';
import 'package:launcher/models/buttons.dart';
import 'package:launcher/theme.dart';
import 'package:launcher/widgets/input_box.dart';

class InputCaptureGrid<K> extends StatefulWidget {
  const InputCaptureGrid({
    required this.columns,
    required this.iconData,
    this.values,
    this.onChanged,
    super.key,
  });

  final int columns;
  final List<List<String>>? values;
  final Map<K, Widget> iconData;
  final void Function(K, VK, int)? onChanged;

  @override
  State<InputCaptureGrid> createState() => _InputCaptureGridState<K>();
}

class _InputCaptureGridState<K> extends State<InputCaptureGrid<K>> {
  @override
  void initState() {
    super.initState();
  }

  String _getDisplayName(int row, int col) {
    if (row < (widget.values?.length ?? -1) &&
        col < (widget.values?[row].length ?? -1)) {
      return widget.values?[row][col] ?? "";
    }

    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WidgetRatios.widgetPadding(scale: 0.5),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.iconData.keys.length, (row) {
              if (row < widget.iconData.length) {
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: widget.iconData.values.elementAt(row),
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
                widget.iconData.length,
                (row) => Row(
                  children: List.generate(
                    widget.columns,
                    (col) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: InputCaptureBox(
                          displayText: _getDisplayName(row, col),
                          onChanged: (event) => widget.onChanged?.call(
                            widget.iconData.keys.elementAt(row),
                            event,
                            col,
                          ),
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
