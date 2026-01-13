import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget child;
  const GradientScaffold({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1, -0.3),
                radius: 1.2,
                colors: [
                  Color.fromARGB(255, 78, 0, 142),
                  Color.fromARGB(255, 0, 49, 102),
                  const Color.fromARGB(255, 110, 0, 135),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
