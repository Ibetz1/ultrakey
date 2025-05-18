import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/auth.dart';
import 'package:ultrakey_ui/models/value_update_event.dart';

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

  Future<void> validateToken(String? token) async {
    if (token == null || !await AuthServer.isTokenValid(token)) {
      AuthServer.state = AuthState.invalidToken;
      AuthServer.currentToken = null;
      return;
    }

    List<String> guilds = await AuthServer.getGuilds(token);

    if (!guilds.contains(AuthServer.guildId)) {
      AuthServer.state = AuthState.nolicense;
      AuthServer.currentToken = token;
      return;
    }

    List<String> roles = await AuthServer.getSubscribed(
      AuthServer.guildId,
      token,
    );

    bool isOwner = roles.contains(AuthServer.ownerId);
    // bool isPremium = roles.contains(AuthServer.premiumId);
    bool isGifted = roles.contains(AuthServer.giftedId);
    bool isRevoked = roles.contains(AuthServer.revokedId);
    bool isLifetime = roles.contains(AuthServer.lifetimeId);
    bool isPlus = roles.contains(AuthServer.ukPlusId);

    AuthServer.currentToken = token;
    AuthStorage.saveToken(token);

    if (isRevoked) {
      AuthServer.state = AuthState.banned;
      return;
    }

    if (isOwner || isLifetime || isPlus || isGifted) {
      AuthServer.state = AuthState.validToken;
      return;
    }

    AuthServer.state = AuthState.nolicense;
  }

  void onValueChanged(ValueUpdateEvent v) {
    String id = v.id;
    dynamic val = v.value;

    Map<String, void Function(dynamic)> idCallbacks = {
      "logout": (v) {
        AuthStorage.delToken();
        AuthServer.state = AuthState.awaitingLogin;
      },
      "login": (v) => AuthServer.state = AuthState.awaitingToken,
      "gotToken": (v) {
        AuthServer.state = AuthState.awaitingToken;
        validateToken(v).then(
          (v) => setState(() {
            AuthServer.notify();
          }),
        );
      },
    };

    idCallbacks[id]?.call(val);

    setState(() {});
    AuthServer.notify();
  }

  @override
  void initState() {
    _valueUpdates = AuthServer.updateStream.listen(onData: onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    _valueUpdates.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AuthServer.state == AuthState.validToken) {
      return widget.valid;
    }

    return widget.login;
  }
}
