import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowAppBar extends StatelessWidget {
  const WindowAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return WindowTitleBarBox(
      child: Row(
        children: [
          Expanded(child: MoveWindow()), // Makes it draggable
          WindowButtons(),
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  WindowButtons({super.key});
  final buttonColors = WindowButtonColors(
    iconNormal: Colors.white,
    mouseOver: Colors.blue,
    mouseDown: Colors.blueAccent,
    iconMouseOver: Colors.white,
    iconMouseDown: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: buttonColors),
      ],
    );
  }
}