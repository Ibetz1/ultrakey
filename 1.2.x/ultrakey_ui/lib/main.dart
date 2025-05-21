import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:ultrakey_ui/containers/login_container.dart';
import 'package:ultrakey_ui/containers/main_container.dart';
import 'package:ultrakey_ui/models/config.dart';
import 'package:ultrakey_ui/models/utils.dart';
import 'package:ultrakey_ui/widgets/auth_state.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/gradient_scaffold.dart';
import 'package:ultrakey_ui/widgets/installer.dart';
import 'package:ultrakey_ui/widgets/windows_buttons.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ScriptLoader.watchScriptFolder((file, event) {
    Config.updateStream.push(id: "scriptChanged", value: {
      file: event,
    });
  });

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
                  valid: Expanded(child: UltrakeyMain()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}