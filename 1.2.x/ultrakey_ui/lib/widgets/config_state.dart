import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/buttons.dart';
import 'package:ultrakey_ui/models/config.dart';
import 'package:ultrakey_ui/models/utils.dart';
import 'package:ultrakey_ui/models/value_update_event.dart';

class ConfigStateContainer extends StatefulWidget {
  const ConfigStateContainer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<ConfigStateContainer> createState() => _ConfigStateContainerState();
}

class _ConfigStateContainerState extends State<ConfigStateContainer> {
  late StreamSubscription<ValueUpdateEvent> _valueUpdates;

  void onValueChanged(ValueUpdateEvent v) {
    String id = v.id;
    dynamic val = v.value;
    int? index = extractTrailingNumber(id);

    Map<String, void Function(dynamic)> idCallbacks = {
      "sensitivity": (v) => Config.sensitivity = (v as int).toDouble(),
      "smoothing": (v) => Config.smoothing = (v as int).toDouble(),
      "stabilizerStrength": (v) =>
          Config.stabilizerStrength = (v as int).toDouble(),
      "keepaliveStrength": (v) =>
          Config.keepaliveStrength = (v as int).toDouble(),
      "stabilizerSpeed": (v) => Config.stabilizerSpeed = (v as int),
      "keepaliveSpeed": (v) => Config.keepaliveSpeed = (v as int),
      "threshold": (v) => Config.threshold = (v as bool),
      "stabilizer": (v) => Config.stabilizer = (v as bool),
      "keepalive": (v) => Config.keepalive = (v as bool),
      "passthrough": (v) => Config.passthrough = (v as bool),
      "rsType": (v) {
        Config.rsBinding = Config.stickRemapping.containsKey(v)
            ? Config.stickRemapping[v]
            : VirtualKey.keyNone.value;
        if (Config.rsBinding != VirtualKey.keyKeyboard.value) {
          Config.rightAnalogBindings.clear();
          Config.grid["rs"] = List.generate(
            Config.gridLengths["rs"]!,
            (i) => VirtualKey.keyNone.value,
          );
        }
      },
      "lsType": (v) {
        Config.lsBinding = Config.stickRemapping.containsKey(v)
            ? Config.stickRemapping[v]
            : VirtualKey.keyNone.value;
        if (Config.lsBinding != VirtualKey.keyKeyboard.value) {
          Config.leftAnalogBindings.clear();
          Config.grid["ls"] = List.generate(
            Config.gridLengths["ls"]!,
            (i) => VirtualKey.keyNone.value,
          );
        }
      },
      "resetConfig": (v) => Config.reset(),
      "changeTaggedBinding": (v) {
        Config.taggedBindings.removeWhere(
          (k1, v1) => v1 == v[1],
        );
        Config.taggedBindings[v[0].toString()] = v[1].toString();
        Config.taggedBindings.removeWhere(
          (k1, v1) => int.parse(k1) == VirtualKey.keyNone.value,
        );
      },
      "changeValueBinding": (v) {
        Config.valueBindings[v[0]] = v[1];
      },
    };

    Map<String, void Function(int, dynamic)> indexedCallbacks = {
      "leftTrigger": (v, col) => Config.setGrid("leftTrigger", col, val),
      "rightTrigger": (v, col) => Config.setGrid("rightTrigger", col, val),
      "toggleTap": (v, col) => Config.setGrid("toggleTap", col, v),
      "toggleHold": (v, col) => Config.setGrid("toggleHold", col, v),
      "untoggleHold": (v, col) => Config.setGrid("untoggleHold", col, v),
      "ls": (v, col) => Config.setGrid("ls", col, v),
      "rs": (v, col) => Config.setGrid("rs", col, v),
      "dpadUp": (v, col) => Config.setGrid("dpadUp", col, v),
      "dpadDown": (v, col) => Config.setGrid("dpadDown", col, v),
      "dpadLeft": (v, col) => Config.setGrid("dpadLeft", col, v),
      "dpadRight": (v, col) => Config.setGrid("dpadRight", col, v),
      "start": (v, col) => Config.setGrid("start", col, v),
      "back": (v, col) => Config.setGrid("back", col, v),
      "leftThumb": (v, col) => Config.setGrid("leftThumb", col, v),
      "rightThumb": (v, col) => Config.setGrid("rightThumb", col, v),
      "leftShoulder": (v, col) => Config.setGrid("leftShoulder", col, v),
      "rightShoulder": (v, col) => Config.setGrid("rightShoulder", col, v),
      "a": (v, col) => Config.setGrid("a", col, v),
      "b": (v, col) => Config.setGrid("b", col, v),
      "x": (v, col) => Config.setGrid("x", col, v),
      "y": (v, col) => Config.setGrid("y", col, v),
    };

    if (index != null) {
      id = stripTrailingNumber(id);
      indexedCallbacks[id]?.call(val, index);
    } else if (idCallbacks.containsKey(id)) {
      idCallbacks[id]?.call(val);
    }

    Config.scanGridRepeats();
    Config.notify();
  }

  @override
  void initState() {
    _valueUpdates = Config.updateStream.listen(onData: onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    _valueUpdates.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
