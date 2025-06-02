import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:launcher/containers/login_container.dart';
import 'package:launcher/containers/main_container.dart';
import 'package:launcher/models/utils.dart';
import 'package:launcher/theme.dart';
import 'package:launcher/widgets/auth_state.dart';
import 'package:launcher/widgets/gradient_scaffold.dart';
import 'package:launcher/widgets/installer.dart';
import 'package:launcher/widgets/windows_buttons.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ScriptLoader.watchScriptFolder((file, event) {
  //   Config.updateStream.push(id: "scriptChanged", value: {
  //     file: event,
  //   });
  // });

  runApp(MainApp());

  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = const Size(1100, 900);
    win.size = const Size(1100, 900);
    win.alignment = Alignment.center;
    win.title = getRandomString(7);
    win.show();
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(context),
      home: GradientScaffold(
        child: Column(
          children: [
            WindowAppBar(),
            Expanded(
              child: UltrakeyInstaller(
                child: AuthStateContainer(
                  login: UltrakeyLogin(),
                  valid: UltrakeyMain(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}