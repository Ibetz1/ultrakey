import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launcher/models/buttons.dart';
import 'package:launcher/models/utils.dart';

class InputCaptureBox extends StatefulWidget {
  const InputCaptureBox({
    this.id,
    this.displayText,
    this.onChanged,
    this.enabled = true,
    this.conflict = false,
    super.key,
  });

  final bool enabled;
  final bool conflict;
  final String? displayText;
  final String? id;
  final void Function(VK)? onChanged;

  @override
  State<InputCaptureBox> createState() => _InputCaptureBoxState();
}

class _InputCaptureBoxState extends State<InputCaptureBox> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(
      (e) => _handleEvent(
        e.logicalKey.keyId,
        keyDown: e is KeyDownEvent,
      ),
    );
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  bool _handleEvent(int keyId, {bool keyDown = true}) {
    if (!_focusNode.hasFocus) return false;
    if (!keyDown) return false;
    if (!widget.enabled) return false;

    VK remapped = VK.fromLogicalKey(keyId);
    if (remapped == VK.keyNone) {
      return false;
    }

    if (remapped == VK.keyBackspace) {
      remapped = VK.keyNone;
    }

    widget.onChanged?.call(remapped);

    return false;
  }

  Color getBackground() {
    if (widget.conflict) {
      return Theme.of(context).colorScheme.error;
    }

    if (!widget.enabled) {
      return Theme.of(context).colorScheme.surface;
    }

    return _focusNode.hasFocus
        ? Theme.of(context).colorScheme.onTertiary
        : Colors.transparent;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(
      (e) => _handleEvent(e.logicalKey.keyId, keyDown: e is KeyDownEvent),
    );
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) => _handleEvent(e.buttons),
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Container(
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: _focusNode.hasFocus && widget.enabled
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onTertiary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(huge),
              color: getBackground(),
            ),
            child: Text(
              widget.displayText ?? "",
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ),
    );
  }
}
