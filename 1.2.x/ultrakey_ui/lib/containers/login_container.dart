import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultrakey_ui/models/auth.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/styled_container.dart';
import 'package:url_launcher/url_launcher.dart';

class UltrakeyLogin extends StatefulWidget {
  const UltrakeyLogin({super.key});

  @override
  State<UltrakeyLogin> createState() => _UltrakeyLoginState();
}

class _UltrakeyLoginState extends State<UltrakeyLogin> {
  late StreamSubscription authUpdates;

  @override
  void initState() {
    AuthServer.start();

    String? token = AuthStorage.loadToken();
    if (token != null) {
      AuthServer.updateStream.push(id: "gotToken", value: token);
    }

    authUpdates = AuthServer.listen((v) {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    authUpdates.cancel();
    super.dispose();
  }

  void _login() {
    AuthServer.openDiscordOAuth();
    AuthServer.updateStream.push(
      id: "login",
      value: null,
    );
  }

  void _logout() {
    AuthServer.updateStream.push(id: "logout", value: null);
  }

  void _purchase() {
    const String storeUrl =
        "https://discord.com/channels/1353186170711965836/shop";
    launchUrl(
      Uri.parse(storeUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  void _refresh() {
    AuthServer.updateStream.push(
      id: "gotToken",
      value: AuthServer.currentToken,
    );
  }

  Widget refreshButton() => SizedBox(
        width: 400,
        height: 40,
        child: FilledButton(
          onPressed: _refresh,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh,
                size: WidgetRatios.smallIconSize,
              ),
              SizedBox(width: WidgetRatios.horizontalPadding),
              Text(
                "Refresh",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                    ),
              ),
            ],
          ),
        ),
      );

  Widget loginButton() => SizedBox(
        width: 400,
        height: 40,
        child: FilledButton(
          onPressed: _login,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login,
                size: WidgetRatios.smallIconSize,
              ),
              SizedBox(width: WidgetRatios.horizontalPadding),
              Text(
                "Sign in with Discord",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                    ),
              ),
            ],
          ),
        ),
      );

  Widget logoutButton() => SizedBox(
        width: 400,
        height: 40,
        child: FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: _logout,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                size: WidgetRatios.smallIconSize,
              ),
              SizedBox(width: WidgetRatios.horizontalPadding),
              Text(
                "Logout",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                    ),
              ),
            ],
          ),
        ),
      );

  Widget purchaseButton() => SizedBox(
        width: 400,
        height: 40,
        child: FilledButton(
          onPressed: _purchase,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart,
                size: WidgetRatios.smallIconSize,
              ),
              SizedBox(width: WidgetRatios.horizontalPadding),
              Text(
                "Purchase",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                    ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: StyledContainer(
            maxWidth: 580,
            height: 450,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 350,
                  child: Image.asset(
                    "assets/signin.png",
                    color: (AuthServer.state == AuthState.invalidToken ||
                            AuthServer.state == AuthState.banned)
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 70),
                Center(
                  child: Column(
                    children: [
                      if (AuthServer.state == AuthState.banned)
                        Text(
                          "You are banned from UltraKey",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                        ),
                      if (AuthServer.state == AuthState.invalidToken) ...[
                        Text(
                          "Login Failed",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                        ),
                        SizedBox(height: 2 * WidgetRatios.verticalPadding),
                      ],
                      if (AuthServer.state == AuthState.awaitingLogin ||
                          AuthServer.state == AuthState.invalidToken)
                        loginButton(),
                      if (AuthServer.state == AuthState.nolicense) ...[
                        purchaseButton(),
                        SizedBox(height: 2 * WidgetRatios.verticalPadding),
                        refreshButton(),
                        SizedBox(height: 2 * WidgetRatios.verticalPadding),
                        logoutButton(),
                      ],
                      if (AuthServer.state == AuthState.awaitingToken)
                        CircularProgressIndicator()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}