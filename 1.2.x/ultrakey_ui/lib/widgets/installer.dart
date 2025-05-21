import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:ultrakey_ui/models/libraries.dart';
import 'package:ultrakey_ui/theme.dart';
import 'package:ultrakey_ui/widgets/styled_container.dart';

class UltrakeyInstaller extends StatefulWidget {
  const UltrakeyInstaller({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<UltrakeyInstaller> createState() => _UltrakeyInstallerState();
}

class _UltrakeyInstallerState extends State<UltrakeyInstaller> {
  int driverBitfield = 0;
  final int interceptionMouse = 1;
  final int interceptionKeyboard = 2;
  final int vigembus = 3;
  bool needRestart = false;

  @override
  void initState() {
    requestAdmin();
    driverBitfield = fetchReqDrivers();
    super.initState();
  }

  bool get hasInterception =>
      (driverBitfield & interceptionMouse != 0) &&
      (driverBitfield & interceptionKeyboard != 0);

  bool get hasVigembus => (driverBitfield & vigembus) != 0;

  void _install() {
    Pointer<Utf8> driverPath = p.join
    (Directory.current.path, "drivers").toNativeUtf8();

    if (!hasInterception) {
      installInterception(driverPath);
    }

    if (!hasVigembus) {
      installVigem(driverPath);
    }

    calloc.free(driverPath);

    setState(() {
      needRestart = true;
    });
  }

  void _restart() {
    restartPc();
  }

  Widget installButton() => SizedBox(
        width: 400,
        height: 40,
        child: FilledButton(
          onPressed: _install,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.build,
                size: WidgetRatios.smallIconSize,
              ),
              SizedBox(width: WidgetRatios.horizontalPadding),
              Text(
                "Install UltraKey",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                    ),
              ),
            ],
          ),
        ),
      );

  Widget restartButton() => SizedBox(
        width: 400,
        height: 40,
        child: FilledButton(
          onPressed: _restart,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.build,
                size: WidgetRatios.smallIconSize,
              ),
              SizedBox(width: WidgetRatios.horizontalPadding),
              Text(
                "Restart PC",
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
    if (hasInterception && hasVigembus) {
      return widget.child;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: StyledContainer(
            maxWidth: 580,
            height: 220,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.install_desktop,
                  size: 64,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(height: 35),
                (needRestart) ? restartButton() : installButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}