from collections import defaultdict
from email.policy import default
from os import dup
import struct
from enum import IntFlag
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QKeySequence
import json

def key_to_string(key):
    return QKeySequence(key).toString()

class VirtualKey(IntFlag):
    KEY_None = 0x00,
    KEY_ESCAPE = 0x01,
    KEY_1 = 0x02,
    KEY_2 = 0x03,
    KEY_3 = 0x04,
    KEY_4 = 0x05,
    KEY_5 = 0x06,
    KEY_6 = 0x07,
    KEY_7 = 0x08,
    KEY_8 = 0x09,
    KEY_9 = 0x0A,
    KEY_0 = 0x0B,
    KEY_MINUS = 0x0C,
    KEY_EQUALS = 0x0D,
    KEY_BACKSPACE = 0x0E,
    KEY_TAB = 0x0F,
    KEY_Q = 0x10,
    KEY_W = 0x11,
    KEY_E = 0x12,
    KEY_R = 0x13,
    KEY_T = 0x14,
    KEY_Y = 0x15,
    KEY_U = 0x16,
    KEY_I = 0x17,
    KEY_O = 0x18,
    KEY_P = 0x19,
    KEY_LEFT_BRACKET = 0x1A,
    KEY_RIGHT_BRACKET = 0x1B,
    KEY_ENTER = 0x1C,
    KEY_LEFT_CTRL = 0x1D,
    KEY_A = 0x1E,
    KEY_S = 0x1F,
    KEY_D = 0x20,
    KEY_F = 0x21,
    KEY_G = 0x22,
    KEY_H = 0x23,
    KEY_J = 0x24,
    KEY_K = 0x25,
    KEY_L = 0x26,
    KEY_SEMICOLON = 0x27,
    KEY_APOSTROPHE = 0x28,
    KEY_GRAVE = 0x29,
    KEY_LEFT_SHIFT = 0x2A,
    KEY_BACKSLASH = 0x2B,
    KEY_Z = 0x2C,
    KEY_X = 0x2D,
    KEY_C = 0x2E,
    KEY_V = 0x2F,
    KEY_B = 0x30,
    KEY_N = 0x31,
    KEY_M = 0x32,
    KEY_COMMA = 0x33,
    KEY_PERIOD = 0x34,
    KEY_SLASH = 0x35,
    KEY_RIGHT_SHIFT = 0x36,
    KEY_KP_MULTIPLY = 0x37,
    KEY_LEFT_ALT = 0x38,
    KEY_SPACE = 0x39,
    KEY_CAPS_LOCK = 0x3A,
    KEY_F1 = 0x3B,
    KEY_F2 = 0x3C,
    KEY_F3 = 0x3D,
    KEY_F4 = 0x3E,
    KEY_F5 = 0x3F,
    KEY_F6 = 0x40,
    KEY_F7 = 0x41,
    KEY_F8 = 0x42,
    KEY_F9 = 0x43,
    KEY_F10 = 0x44,
    KEY_NUM_LOCK = 0x45,
    KEY_SCROLL_LOCK = 0x46,
    KEY_KP_7 = 0x47,
    KEY_KP_8 = 0x48,
    KEY_KP_9 = 0x49,
    KEY_KP_MINUS = 0x4A,
    KEY_KP_4 = 0x4B,
    KEY_KP_5 = 0x4C,
    KEY_KP_6 = 0x4D,
    KEY_KP_PLUS = 0x4E,
    KEY_KP_1 = 0x4F,
    KEY_KP_2 = 0x50,
    KEY_KP_3 = 0x51,
    KEY_KP_0 = 0x52,
    KEY_KP_DECIMAL = 0x53,
    KEY_KP_ENTER = 0x01C,
    KEY_RIGHT_CTRL = 0x01D,
    KEY_KP_DIVIDE = 0x035,
    KEY_RIGHT_ALT = 0x038,
    KEY_HOME = 0x047,
    KEY_UP = 0x048,
    KEY_PAGE_UP = 0x049,
    KEY_LEFT = 0x04B,
    KEY_RIGHT = 0x04D,
    KEY_END = 0x04F,
    KEY_DOWN = 0x050,
    KEY_PAGE_DOWN = 0x051,
    KEY_INSERT = 0x052,
    KEY_DELETE = 0x053,
    KEY_LEFT_WINDOWS = 0x05B,
    KEY_RIGHT_WINDOWS = 0x05C,
    KEY_APPLICATION = 0x05D,
    KEY_MOUSE = 0x05E,
    KEY_MOUSE_LB = 0x05F,
    KEY_MOUSE_RB = 0x060,
    KEY_MOUSE_MB = 0x061,
    KEY_MOUSE_MW = 0x062,
    KEY_KEYBOARD = 0x063,
    KEY_MAX = 99,

class ButtonCode(IntFlag):
    GAMEPAD_DPAD_UP = 0x0001
    GAMEPAD_DPAD_DOWN = 0x0002
    GAMEPAD_DPAD_LEFT = 0x0004
    GAMEPAD_DPAD_RIGHT = 0x0008
    GAMEPAD_START = 0x0010
    GAMEPAD_BACK = 0x0020
    GAMEPAD_LEFT_THUMB = 0x0040
    GAMEPAD_RIGHT_THUMB = 0x0080
    GAMEPAD_LEFT_SHOULDER = 0x0100
    GAMEPAD_RIGHT_SHOULDER = 0x0200
    GAMEPAD_GUIDE = 0x0400
    GAMEPAD_A = 0x1000
    GAMEPAD_B = 0x2000
    GAMEPAD_X = 0x4000
    GAMEPAD_Y = 0x8000
    LSTICK = 0x8001
    RSTICK = 0x8002
    PASS = 0x0000

QT_TO_VIRTUAL_KEY_MAP = {
    'ENTER': VirtualKey.KEY_ENTER.value,
    'ENTER': VirtualKey.KEY_ENTER.value,
    'SPACE': VirtualKey.KEY_SPACE.value,
    'TAB': VirtualKey.KEY_TAB.value,
    'ESCAPE': VirtualKey.KEY_ESCAPE.value,
    'LEFT': VirtualKey.KEY_LEFT.value,
    'RIGHT': VirtualKey.KEY_RIGHT.value,
    'UP': VirtualKey.KEY_UP.value,
    'DOWN': VirtualKey.KEY_DOWN.value,
    "CTRL": VirtualKey.KEY_LEFT_CTRL.value,
    "ALT": VirtualKey.KEY_LEFT_ALT.value,
    "SHIFT": VirtualKey.KEY_LEFT_SHIFT.value,
    "CAPS": VirtualKey.KEY_CAPS_LOCK.value,
    "F1": VirtualKey.KEY_F1.value,
    "F2": VirtualKey.KEY_F2.value,
    "F3": VirtualKey.KEY_F3.value,
    "F4": VirtualKey.KEY_F4.value,
    "F5": VirtualKey.KEY_F5.value,
    "F6": VirtualKey.KEY_F6.value,
    "F7": VirtualKey.KEY_F7.value,
    "F8": VirtualKey.KEY_F8.value,
    "F9": VirtualKey.KEY_F9.value,
    "F10": VirtualKey.KEY_F10.value,
    'LEFT_CLICK': VirtualKey.KEY_MOUSE_LB.value,
    'RIGHT_CLICK': VirtualKey.KEY_MOUSE_RB.value,

    key_to_string(Qt.Key.Key_Left): VirtualKey.KEY_LEFT.value,
    key_to_string(Qt.Key.Key_Up): VirtualKey.KEY_UP.value,
    key_to_string(Qt.Key.Key_Right): VirtualKey.KEY_RIGHT.value,
    key_to_string(Qt.Key.Key_Down): VirtualKey.KEY_DOWN.value,
    key_to_string(Qt.Key.Key_Equal) : VirtualKey.KEY_EQUALS.value,

    key_to_string(Qt.Key.Key_0) : VirtualKey.KEY_0.value,
    key_to_string(Qt.Key.Key_1) : VirtualKey.KEY_1.value,
    key_to_string(Qt.Key.Key_2) : VirtualKey.KEY_2.value,
    key_to_string(Qt.Key.Key_3) : VirtualKey.KEY_3.value,
    key_to_string(Qt.Key.Key_4) : VirtualKey.KEY_4.value,
    key_to_string(Qt.Key.Key_5) : VirtualKey.KEY_5.value,
    key_to_string(Qt.Key.Key_6) : VirtualKey.KEY_6.value,
    key_to_string(Qt.Key.Key_7) : VirtualKey.KEY_7.value,
    key_to_string(Qt.Key.Key_8) : VirtualKey.KEY_8.value,
    key_to_string(Qt.Key.Key_9) : VirtualKey.KEY_9.value,
    key_to_string(Qt.Key.Key_A) : VirtualKey.KEY_A.value,
    key_to_string(Qt.Key.Key_B) : VirtualKey.KEY_B.value,
    key_to_string(Qt.Key.Key_C) : VirtualKey.KEY_C.value,
    key_to_string(Qt.Key.Key_D) : VirtualKey.KEY_D.value,
    key_to_string(Qt.Key.Key_E) : VirtualKey.KEY_E.value,
    key_to_string(Qt.Key.Key_F) : VirtualKey.KEY_F.value,
    key_to_string(Qt.Key.Key_G) : VirtualKey.KEY_G.value,
    key_to_string(Qt.Key.Key_H) : VirtualKey.KEY_H.value,
    key_to_string(Qt.Key.Key_I) : VirtualKey.KEY_I.value,
    key_to_string(Qt.Key.Key_J) : VirtualKey.KEY_J.value,
    key_to_string(Qt.Key.Key_K) : VirtualKey.KEY_K.value,
    key_to_string(Qt.Key.Key_L) : VirtualKey.KEY_L.value,
    key_to_string(Qt.Key.Key_M) : VirtualKey.KEY_M.value,
    key_to_string(Qt.Key.Key_N) : VirtualKey.KEY_N.value,
    key_to_string(Qt.Key.Key_O) : VirtualKey.KEY_O.value,
    key_to_string(Qt.Key.Key_P) : VirtualKey.KEY_P.value,
    key_to_string(Qt.Key.Key_Q) : VirtualKey.KEY_Q.value,
    key_to_string(Qt.Key.Key_R) : VirtualKey.KEY_R.value,
    key_to_string(Qt.Key.Key_S) : VirtualKey.KEY_S.value,
    key_to_string(Qt.Key.Key_T) : VirtualKey.KEY_T.value,
    key_to_string(Qt.Key.Key_U) : VirtualKey.KEY_U.value,
    key_to_string(Qt.Key.Key_V) : VirtualKey.KEY_V.value,
    key_to_string(Qt.Key.Key_W) : VirtualKey.KEY_W.value,
    key_to_string(Qt.Key.Key_X) : VirtualKey.KEY_X.value,
    key_to_string(Qt.Key.Key_Y) : VirtualKey.KEY_Y.value,
    key_to_string(Qt.Key.Key_Z) : VirtualKey.KEY_Z.value,
}

VIRTUAL_TO_QT_KEY_MAP = {v: k for k, v in QT_TO_VIRTUAL_KEY_MAP.items()}

class InputRemapper:
    def __init__(self):
        self.left_analog_bindings: dict = {}
        self.right_analog_bindings: dict = {}
        self.button_bindings: dict = {}
        self.toggle_bindings: dict = {}
        self.flagged_bindings: dict = {}
        self.value_bindings: dict = {}
        self.scripts: list = []
        self.lt_binding: int = 0
        self.rt_binding: int = 0
        self.ls_binding: int = VirtualKey.KEY_KEYBOARD.value
        self.rs_binding: int = VirtualKey.KEY_MOUSE.value
        self.threshold: bool = False
        self.sensitivity: float = 0.05

    def export_bytes(self):
        data = {
            "left_analog_bindings": self.left_analog_bindings,
            "right_analog_bindings": self.right_analog_bindings,
            "button_bindings": self.button_bindings,
            "toggle_bindings": self.toggle_bindings,
            "scripts": self.scripts,
            "lt_binding": self.lt_binding,
            "rt_binding": self.rt_binding,
            "ls_binding": self.ls_binding,
            "rs_binding": self.rs_binding,
            "threshold": self.threshold,
            "sensitivity": self.sensitivity,
            "tagged_bindings": self.flagged_bindings,
            "value_bindings": self.value_bindings
        }
        
        json_data = json.dumps(data, indent=2)
        return json_data.encode("utf-8")
    
    def import_bytes(self, byte_data: bytes):
        try:
            data = json.loads(byte_data.decode("utf-8"))

            self.left_analog_bindings = data.get("left_analog_bindings", {})
            self.right_analog_bindings = data.get("right_analog_bindings", {})
            self.button_bindings = data.get("button_bindings", {})
            self.toggle_bindings = data.get("toggle_bindings", {})
            self.flagged_bindings = data.get("tagged_bindings", {})
            self.value_bindings = data.get("value_bindings", {})
            self.scripts = data.get("scripts", [])
            self.lt_binding = data.get("lt_binding", 0)
            self.rt_binding = data.get("rt_binding", 0)
            self.ls_binding = data.get("ls_binding", 0)
            self.rs_binding = data.get("rs_binding", 0)
            self.threshold = data.get("threshold", False)
            self.sensitivity = data.get("sensitivity", 0)
        except:
            print("failed to load cfg data")