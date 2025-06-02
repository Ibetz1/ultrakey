import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:launcher/models/auth.dart';
import 'package:launcher/models/value_update_event.dart';

class AuthStateContainer extends StatefulWidget {
  const AuthStateContainer({
    required this.login,
    required this.valid,
    super.key,
  });

  final Widget login;
  final Widget valid;

  @override
  State<AuthStateContainer> createState() => _AuthStateContainerState();
}

class _AuthStateContainerState extends State<AuthStateContainer> {
  late StreamSubscription<ValueUpdateEvent> _valueUpdates;
  late StreamSubscription authUpdates;

  void onValueChanged(ValueUpdateEvent v) {
    v.call();
    AuthServer.notify();
  }

  @override
  void initState() {
    _valueUpdates = AuthServer.updateStream.listen(
      onData: onValueChanged,
    );
    authUpdates = AuthServer.listen((v) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _valueUpdates.cancel();
    authUpdates.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AuthServer.state == AuthState.validToken || kDebugMode) {
      return widget.valid;
    }

    return widget.login;
  }
}
