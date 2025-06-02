import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:launcher/models/assets.dart';

enum ToggleMode {
  singlePress(0x0),
  hold(0x1),
  holdUntoggle(0x2);

  final int value;
  const ToggleMode(this.value);

  static Map<ToggleMode, Widget> icons = {
    ToggleMode.singlePress: SizedBox(
      width: 60,
      child: Center(child: Text("Tap")),
    ),
    ToggleMode.hold: SizedBox(
      width: 60,
      child: Center(child: Text("Hold")),
    ),
    ToggleMode.holdUntoggle: SizedBox(
      width: 60,
      child: Center(child: Text("Untoggle")),
    ),
  };

  static ToggleMode? from(int value) {
    for (final code in ToggleMode.values) {
      if (code.value == value) return code;
    }
    return null;
  }
}

enum GamepadTrigger {
  lt(0x0),
  rt(0x1);

  final int value;
  const GamepadTrigger(this.value);

  static Map<GamepadTrigger, Widget> icons = {
    lt: leftTriggerImage,
    rt: rightTriggerImage,
  };
}

enum GamepadCode {
  a(0x1000),
  b(0x2000),
  x(0x4000),
  y(0x8000),
  dpadUp(0x0001),
  dpadDown(0x0002),
  dpadLeft(0x0004),
  dpadRight(0x0008),
  start(0x0010),
  back(0x0020),
  leftThumb(0x0040),
  rightThumb(0x0080),
  leftShoulder(0x0100),
  rightShoulder(0x0200),
  guide(0x0400),
  lStick(0x8001),
  rStick(0x8002);

  final int value;
  const GamepadCode(this.value);

  static GamepadCode? fromString(String name) {
    for (final code in GamepadCode.values) {
      if (code.name == name) return code;
    }
    return null;
  }

  static GamepadCode? from(int value) {
    for (final code in GamepadCode.values) {
      if (code.value == value) return code;
    }
    return null;
  }

  static List<String> makeIdTable() {
    return GamepadCode.values.map((e) => e.name).toList();
  }

  static Map<GamepadCode, Image> icons = {
    a: aFilledImage,
    b: bFilledImage,
    x: xFilledImage,
    y: yFilledImage,
    dpadUp: dpadUpImage,
    dpadDown: dpadDownImage,
    dpadLeft: dpadLeftImage,
    dpadRight: dpadRightImage,
    start: menuImage,
    back: viewImage,
    leftThumb: leftJoystickPressImage,
    rightThumb: rightJoystickPressImage,
    leftShoulder: leftBumperImage,
    rightShoulder: rightBumperImage,
  };
}

enum VK {
  keyNone(0x00),
  keyEscape(0x01),
  key1(0x02),
  key2(0x03),
  key3(0x04),
  key4(0x05),
  key5(0x06),
  key6(0x07),
  key7(0x08),
  key8(0x09),
  key9(0x0A),
  key0(0x0B),
  keyMinus(0x0C),
  keyEquals(0x0D),
  keyBackspace(0x0E),
  keyTab(0x0F),
  keyQ(0x10),
  keyW(0x11),
  keyE(0x12),
  keyR(0x13),
  keyT(0x14),
  keyY(0x15),
  keyU(0x16),
  keyI(0x17),
  keyO(0x18),
  keyP(0x19),
  keyLeftBracket(0x1A),
  keyRightBracket(0x1B),
  keyEnter(0x1C),
  keyLeftCtrl(0x1D),
  keyA(0x1E),
  keyS(0x1F),
  keyD(0x20),
  keyF(0x21),
  keyG(0x22),
  keyH(0x23),
  keyJ(0x24),
  keyK(0x25),
  keyL(0x26),
  keySemicolon(0x27),
  keyApostrophe(0x28),
  keyGrave(0x29),
  keyLeftShift(0x2A),
  keyBackslash(0x2B),
  keyZ(0x2C),
  keyX(0x2D),
  keyC(0x2E),
  keyV(0x2F),
  keyB(0x30),
  keyN(0x31),
  keyM(0x32),
  keyComma(0x33),
  keyPeriod(0x34),
  keySlash(0x35),
  keyRightShift(0x36),
  keyKpMultiply(0x37),
  keyLeftAlt(0x38),
  keySpace(0x39),
  keyCapsLock(0x3A),
  keyF1(0x3B),
  keyF2(0x3C),
  keyF3(0x3D),
  keyF4(0x3E),
  keyF5(0x3F),
  keyF6(0x40),
  keyF7(0x41),
  keyF8(0x42),
  keyF9(0x43),
  keyF10(0x44),
  keyNumLock(0x45),
  keyScrollLock(0x46),
  keyKp7(0x47),
  keyKp8(0x48),
  keyKp9(0x49),
  keyKpMinus(0x4A),
  keyKp4(0x4B),
  keyKp5(0x4C),
  keyKp6(0x4D),
  keyKpPlus(0x4E),
  keyKp1(0x4F),
  keyKp2(0x50),
  keyKp3(0x51),
  keyKp0(0x52),
  keyKpDecimal(0x53),
  keyKpEnter(0x01C),
  keyRightCtrl(0x01D),
  keyKpDivide(0x035),
  keyRightAlt(0x038),
  keyHome(0x047),
  keyUp(0x048),
  keyPageUp(0x049),
  keyLeft(0x04B),
  keyRight(0x04D),
  keyEnd(0x04F),
  keyDown(0x050),
  keyPageDown(0x051),
  keyInsert(0x052),
  keyDelete(0x053),
  keyLeftWindows(0x05B),
  keyRightWindows(0x05C),
  keyApplication(0x05D),
  keyMouse(0x05E),
  keyMouseLb(0x05F),
  keyMouseRb(0x060),
  keyMouseMb(0x061),
  keyMouseMw(0x062),
  keyMouse4(0x063),
  keyMouse5(0x064),
  keyKeyboard(0x065),
  keyMax(99);

  final int value;
  const VK(this.value);

  static VK fromLogicalKey(int logical) {
    return keyMap[logical] ?? VK.keyNone;
  }

  static String displayName(VK? nonLogical) {
    return displayMap[nonLogical]?.toUpperCase() ?? "UNKNOWN";
  }

  static VK from(int? value) {
    if (value == null) {
      return VK.keyNone;
    }
    return VK.values.firstWhere((e) => e.value == value);
  }
}

final Map<int, VK> keyMap = {
  kPrimaryMouseButton: VK.keyMouseLb,
  kSecondaryMouseButton: VK.keyMouseRb,
  kMiddleMouseButton: VK.keyMouseMb,
  kForwardMouseButton: VK.keyMouse5,
  kBackMouseButton: VK.keyMouse4,
  LogicalKeyboardKey.tab.keyId: VK.keyTab,
  LogicalKeyboardKey.keyQ.keyId: VK.keyQ,
  LogicalKeyboardKey.keyW.keyId: VK.keyW,
  LogicalKeyboardKey.keyE.keyId: VK.keyE,
  LogicalKeyboardKey.keyR.keyId: VK.keyR,
  LogicalKeyboardKey.keyT.keyId: VK.keyT,
  LogicalKeyboardKey.keyY.keyId: VK.keyY,
  LogicalKeyboardKey.keyU.keyId: VK.keyU,
  LogicalKeyboardKey.keyI.keyId: VK.keyI,
  LogicalKeyboardKey.keyO.keyId: VK.keyO,
  LogicalKeyboardKey.keyP.keyId: VK.keyP,
  LogicalKeyboardKey.keyA.keyId: VK.keyA,
  LogicalKeyboardKey.keyS.keyId: VK.keyS,
  LogicalKeyboardKey.keyD.keyId: VK.keyD,
  LogicalKeyboardKey.keyF.keyId: VK.keyF,
  LogicalKeyboardKey.keyG.keyId: VK.keyG,
  LogicalKeyboardKey.keyH.keyId: VK.keyH,
  LogicalKeyboardKey.keyJ.keyId: VK.keyJ,
  LogicalKeyboardKey.keyK.keyId: VK.keyK,
  LogicalKeyboardKey.keyL.keyId: VK.keyL,
  LogicalKeyboardKey.keyZ.keyId: VK.keyZ,
  LogicalKeyboardKey.keyX.keyId: VK.keyX,
  LogicalKeyboardKey.keyC.keyId: VK.keyC,
  LogicalKeyboardKey.keyV.keyId: VK.keyV,
  LogicalKeyboardKey.keyB.keyId: VK.keyB,
  LogicalKeyboardKey.keyN.keyId: VK.keyN,
  LogicalKeyboardKey.keyM.keyId: VK.keyM,
  LogicalKeyboardKey.escape.keyId: VK.keyEscape,
  LogicalKeyboardKey.digit1.keyId: VK.key1,
  LogicalKeyboardKey.digit2.keyId: VK.key2,
  LogicalKeyboardKey.digit3.keyId: VK.key3,
  LogicalKeyboardKey.digit4.keyId: VK.key4,
  LogicalKeyboardKey.digit5.keyId: VK.key5,
  LogicalKeyboardKey.digit6.keyId: VK.key6,
  LogicalKeyboardKey.digit7.keyId: VK.key7,
  LogicalKeyboardKey.digit8.keyId: VK.key8,
  LogicalKeyboardKey.digit9.keyId: VK.key9,
  LogicalKeyboardKey.digit0.keyId: VK.key0,
  LogicalKeyboardKey.minus.keyId: VK.keyMinus,
  LogicalKeyboardKey.equal.keyId: VK.keyEquals,
  LogicalKeyboardKey.backspace.keyId: VK.keyBackspace,
  LogicalKeyboardKey.bracketLeft.keyId: VK.keyLeftBracket,
  LogicalKeyboardKey.bracketRight.keyId: VK.keyRightBracket,
  LogicalKeyboardKey.enter.keyId: VK.keyEnter,
  LogicalKeyboardKey.controlLeft.keyId: VK.keyLeftCtrl,
  LogicalKeyboardKey.comma.keyId: VK.keyComma,
  LogicalKeyboardKey.period.keyId: VK.keyPeriod,
  LogicalKeyboardKey.slash.keyId: VK.keySlash,
  LogicalKeyboardKey.shiftRight.keyId: VK.keyRightShift,
  LogicalKeyboardKey.altLeft.keyId: VK.keyLeftAlt,
  LogicalKeyboardKey.space.keyId: VK.keySpace,
  LogicalKeyboardKey.capsLock.keyId: VK.keyCapsLock,
  LogicalKeyboardKey.semicolon.keyId: VK.keySemicolon,
  LogicalKeyboardKey.quote.keyId: VK.keyApostrophe,
  LogicalKeyboardKey.backquote.keyId: VK.keyGrave,
  LogicalKeyboardKey.shiftLeft.keyId: VK.keyLeftShift,
  LogicalKeyboardKey.backslash.keyId: VK.keyBackslash,
  LogicalKeyboardKey.f1.keyId: VK.keyF1,
  LogicalKeyboardKey.f2.keyId: VK.keyF2,
  LogicalKeyboardKey.f3.keyId: VK.keyF3,
  LogicalKeyboardKey.f4.keyId: VK.keyF4,
  LogicalKeyboardKey.f5.keyId: VK.keyF5,
  LogicalKeyboardKey.f6.keyId: VK.keyF6,
  LogicalKeyboardKey.f7.keyId: VK.keyF7,
  LogicalKeyboardKey.f8.keyId: VK.keyF8,
  LogicalKeyboardKey.f9.keyId: VK.keyF9,
  LogicalKeyboardKey.f10.keyId: VK.keyF10,
  LogicalKeyboardKey.numLock.keyId: VK.keyNumLock,
  LogicalKeyboardKey.scrollLock.keyId: VK.keyScrollLock,
  LogicalKeyboardKey.home.keyId: VK.keyHome,
  LogicalKeyboardKey.arrowUp.keyId: VK.keyUp,
  LogicalKeyboardKey.pageUp.keyId: VK.keyPageUp,
  LogicalKeyboardKey.arrowLeft.keyId: VK.keyLeft,
  LogicalKeyboardKey.arrowRight.keyId: VK.keyRight,
  LogicalKeyboardKey.end.keyId: VK.keyEnd,
  LogicalKeyboardKey.arrowDown.keyId: VK.keyDown,
  LogicalKeyboardKey.pageDown.keyId: VK.keyPageDown,
  LogicalKeyboardKey.insert.keyId: VK.keyInsert,
  LogicalKeyboardKey.delete.keyId: VK.keyDelete,
  LogicalKeyboardKey.metaLeft.keyId: VK.keyLeftWindows,
  LogicalKeyboardKey.metaRight.keyId: VK.keyRightWindows,
  LogicalKeyboardKey.contextMenu.keyId: VK.keyApplication,
  LogicalKeyboardKey.numpadMultiply.keyId: VK.keyKpMultiply,
  LogicalKeyboardKey.numpadAdd.keyId: VK.keyKpPlus,
  LogicalKeyboardKey.numpadSubtract.keyId: VK.keyKpMinus,
  LogicalKeyboardKey.numpadDivide.keyId: VK.keyKpDivide,
  LogicalKeyboardKey.numpadEnter.keyId: VK.keyKpEnter,
  LogicalKeyboardKey.numpadDecimal.keyId: VK.keyKpDecimal,
  LogicalKeyboardKey.numpad1.keyId: VK.keyKp1,
  LogicalKeyboardKey.numpad2.keyId: VK.keyKp2,
  LogicalKeyboardKey.numpad3.keyId: VK.keyKp3,
  LogicalKeyboardKey.numpad4.keyId: VK.keyKp4,
  LogicalKeyboardKey.numpad5.keyId: VK.keyKp5,
  LogicalKeyboardKey.numpad6.keyId: VK.keyKp6,
  LogicalKeyboardKey.numpad7.keyId: VK.keyKp7,
  LogicalKeyboardKey.numpad8.keyId: VK.keyKp8,
  LogicalKeyboardKey.numpad9.keyId: VK.keyKp9,
  LogicalKeyboardKey.numpad0.keyId: VK.keyKp0,
  LogicalKeyboardKey.controlRight.keyId: VK.keyRightCtrl,
  LogicalKeyboardKey.altRight.keyId: VK.keyRightAlt,
};

final Map<VK, String?> displayMap = {
  VK.keyNone: "",
  VK.keyMouseLb: "MOUSE_LEFT",
  VK.keyMouseRb: "MOUSE_RIGHT",
  VK.keyMouseMb: "MOUSE_MIDDLe",
  VK.keyMouse4: "MOUSE_4",
  VK.keyMouse5: "MOUSE_5",
  VK.keyTab: LogicalKeyboardKey.tab.keyLabel,
  VK.keyQ: LogicalKeyboardKey.keyQ.keyLabel,
  VK.keyW: LogicalKeyboardKey.keyW.keyLabel,
  VK.keyE: LogicalKeyboardKey.keyE.keyLabel,
  VK.keyR: LogicalKeyboardKey.keyR.keyLabel,
  VK.keyT: LogicalKeyboardKey.keyT.keyLabel,
  VK.keyY: LogicalKeyboardKey.keyY.keyLabel,
  VK.keyU: LogicalKeyboardKey.keyU.keyLabel,
  VK.keyI: LogicalKeyboardKey.keyI.keyLabel,
  VK.keyO: LogicalKeyboardKey.keyO.keyLabel,
  VK.keyP: LogicalKeyboardKey.keyP.keyLabel,
  VK.keyA: LogicalKeyboardKey.keyA.keyLabel,
  VK.keyS: LogicalKeyboardKey.keyS.keyLabel,
  VK.keyD: LogicalKeyboardKey.keyD.keyLabel,
  VK.keyF: LogicalKeyboardKey.keyF.keyLabel,
  VK.keyG: LogicalKeyboardKey.keyG.keyLabel,
  VK.keyH: LogicalKeyboardKey.keyH.keyLabel,
  VK.keyJ: LogicalKeyboardKey.keyJ.keyLabel,
  VK.keyK: LogicalKeyboardKey.keyK.keyLabel,
  VK.keyL: LogicalKeyboardKey.keyL.keyLabel,
  VK.keyZ: LogicalKeyboardKey.keyZ.keyLabel,
  VK.keyX: LogicalKeyboardKey.keyX.keyLabel,
  VK.keyC: LogicalKeyboardKey.keyC.keyLabel,
  VK.keyV: LogicalKeyboardKey.keyV.keyLabel,
  VK.keyB: LogicalKeyboardKey.keyB.keyLabel,
  VK.keyN: LogicalKeyboardKey.keyN.keyLabel,
  VK.keyM: LogicalKeyboardKey.keyM.keyLabel,
  VK.key1: LogicalKeyboardKey.digit1.keyLabel,
  VK.key2: LogicalKeyboardKey.digit2.keyLabel,
  VK.key3: LogicalKeyboardKey.digit3.keyLabel,
  VK.key4: LogicalKeyboardKey.digit4.keyLabel,
  VK.key5: LogicalKeyboardKey.digit5.keyLabel,
  VK.key6: LogicalKeyboardKey.digit6.keyLabel,
  VK.key7: LogicalKeyboardKey.digit7.keyLabel,
  VK.key8: LogicalKeyboardKey.digit8.keyLabel,
  VK.key9: LogicalKeyboardKey.digit9.keyLabel,
  VK.key0: LogicalKeyboardKey.digit0.keyLabel,
  VK.keyEscape: LogicalKeyboardKey.escape.keyLabel,
  VK.keyMinus: LogicalKeyboardKey.minus.keyLabel,
  VK.keyEquals: LogicalKeyboardKey.equal.keyLabel,
  VK.keyBackspace: LogicalKeyboardKey.backspace.keyLabel,
  VK.keyLeftBracket: LogicalKeyboardKey.bracketLeft.keyLabel,
  VK.keyRightBracket: LogicalKeyboardKey.bracketRight.keyLabel,
  VK.keyEnter: "ENTER",
  VK.keyLeftCtrl: "LCTRL",
  VK.keyComma: LogicalKeyboardKey.comma.keyLabel,
  VK.keyPeriod: LogicalKeyboardKey.period.keyLabel,
  VK.keySlash: LogicalKeyboardKey.slash.keyLabel,
  VK.keyRightShift: "RSHIFT",
  VK.keyLeftAlt: "ALT",
  VK.keySpace: "SPACE",
  VK.keyCapsLock: "CAPS",
  VK.keySemicolon: LogicalKeyboardKey.semicolon.keyLabel,
  VK.keyApostrophe: LogicalKeyboardKey.quote.keyLabel,
  VK.keyGrave: LogicalKeyboardKey.backquote.keyLabel,
  VK.keyLeftShift: "LSHIFT",
  VK.keyBackslash: LogicalKeyboardKey.backslash.keyLabel,
  VK.keyF1: LogicalKeyboardKey.f1.keyLabel,
  VK.keyF2: LogicalKeyboardKey.f2.keyLabel,
  VK.keyF3: LogicalKeyboardKey.f3.keyLabel,
  VK.keyF4: LogicalKeyboardKey.f4.keyLabel,
  VK.keyF5: LogicalKeyboardKey.f5.keyLabel,
  VK.keyF6: LogicalKeyboardKey.f6.keyLabel,
  VK.keyF7: LogicalKeyboardKey.f7.keyLabel,
  VK.keyF8: LogicalKeyboardKey.f8.keyLabel,
  VK.keyF9: LogicalKeyboardKey.f9.keyLabel,
  VK.keyF10: LogicalKeyboardKey.f10.keyLabel,
  VK.keyNumLock: LogicalKeyboardKey.numLock.keyLabel,
  VK.keyScrollLock: LogicalKeyboardKey.scrollLock.keyLabel,
  VK.keyHome: LogicalKeyboardKey.home.keyLabel,
  VK.keyUp: LogicalKeyboardKey.arrowUp.keyLabel,
  VK.keyPageUp: LogicalKeyboardKey.pageUp.keyLabel,
  VK.keyLeft: LogicalKeyboardKey.arrowLeft.keyLabel,
  VK.keyRight: LogicalKeyboardKey.arrowRight.keyLabel,
  VK.keyEnd: LogicalKeyboardKey.end.keyLabel,
  VK.keyDown: LogicalKeyboardKey.arrowDown.keyLabel,
  VK.keyPageDown: LogicalKeyboardKey.pageDown.keyLabel,
  VK.keyInsert: LogicalKeyboardKey.insert.keyLabel,
  VK.keyDelete: LogicalKeyboardKey.delete.keyLabel,
  VK.keyLeftWindows: LogicalKeyboardKey.metaLeft.keyLabel,
  VK.keyRightWindows: LogicalKeyboardKey.metaRight.keyLabel,
  VK.keyApplication: LogicalKeyboardKey.contextMenu.keyLabel,
  VK.keyKpMultiply: LogicalKeyboardKey.numpadMultiply.keyLabel,
  VK.keyKpPlus: LogicalKeyboardKey.numpadAdd.keyLabel,
  VK.keyKpMinus: LogicalKeyboardKey.numpadSubtract.keyLabel,
  VK.keyKpDivide: "DIVIDE",
  VK.keyKpEnter: "ENTER",
  VK.keyKpDecimal: LogicalKeyboardKey.numpadDecimal.keyLabel,
  VK.keyKp1: LogicalKeyboardKey.numpad1.keyLabel,
  VK.keyKp2: LogicalKeyboardKey.numpad2.keyLabel,
  VK.keyKp3: LogicalKeyboardKey.numpad3.keyLabel,
  VK.keyKp4: LogicalKeyboardKey.numpad4.keyLabel,
  VK.keyKp5: LogicalKeyboardKey.numpad5.keyLabel,
  VK.keyKp6: LogicalKeyboardKey.numpad6.keyLabel,
  VK.keyKp7: LogicalKeyboardKey.numpad7.keyLabel,
  VK.keyKp8: LogicalKeyboardKey.numpad8.keyLabel,
  VK.keyKp9: LogicalKeyboardKey.numpad9.keyLabel,
  VK.keyKp0: LogicalKeyboardKey.numpad0.keyLabel,
  VK.keyRightCtrl: "RCTRL",
  VK.keyRightAlt: "ALT",
};
