import 'package:flutter/material.dart';
import 'package:ultrakey_ui/theme.dart';

class StyledContainer extends StatelessWidget {
  const StyledContainer({
    required this.child,
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.paddingScale = 1,
    super.key,
  });

  final double? paddingScale;
  final double? width;
  final double? height;
  final double? maxWidth;
  final double? maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withAlpha(128),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: WidgetRatios.widgetPadding(scale: paddingScale ?? 0),
          child: child,
        ),
      ),
    );
  }
}
