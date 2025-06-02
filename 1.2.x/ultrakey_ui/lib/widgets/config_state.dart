import 'dart:async';
import 'package:flutter/material.dart';
import 'package:launcher/models/config.dart';
import 'package:launcher/models/script.dart';
import 'package:launcher/models/value_update_event.dart';

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
    v.call();
    ConfigController.notify();
  }

  @override
  void initState() {
    _valueUpdates = ConfigController.updateStream.listen(
      onData: onValueChanged,
    );
    ScriptLoader.importDir().then(
      (_) => ConfigLoader.importDir().then(
        (_) => ConfigController.notify(),
      ),
    );
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
