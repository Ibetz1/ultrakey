import 'package:flutter/material.dart';

class ResponsiveWidget extends StatefulWidget {
  const ResponsiveWidget({
    required this.child,
    this.onResize,
    super.key,
  });

  final Widget child;
  final void Function()? onResize;

  @override
  State<ResponsiveWidget> createState() => _ResponsiveWidgetState();
}

class _ResponsiveWidgetState extends State<ResponsiveWidget> {
  Size? _lastSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final currentSize = Size(constraints.maxWidth, constraints.maxHeight);

        if (_lastSize == null || _lastSize != currentSize) {
          _lastSize = currentSize;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              widget.onResize?.call();
            });
          });
        }

        return widget.child;
      },
    );
  }
}
