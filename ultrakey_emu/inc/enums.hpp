#ifndef _ENUMS_HPP
#define _ENUMS_HPP

enum VirtualKey {
    VKEY_None = 0x00,
    VKEY_ESCAPE = 0x01,
    VKEY_1 = 0x02,
    VKEY_2 = 0x03,
    VKEY_3 = 0x04,
    VKEY_4 = 0x05,
    VKEY_5 = 0x06,
    VKEY_6 = 0x07,
    VKEY_7 = 0x08,
    VKEY_8 = 0x09,
    VKEY_9 = 0x0A,
    VKEY_0 = 0x0B,
    VKEY_MINUS = 0x0C,       // -
    VKEY_EQUALS = 0x0D,      // =
    VKEY_BACKSPACE = 0x0E,
    VKEY_TAB = 0x0F,
    VKEY_Q = 0x10,
    VKEY_W = 0x11,
    VKEY_E = 0x12,
    VKEY_R = 0x13,
    VKEY_T = 0x14,
    VKEY_Y = 0x15,
    VKEY_U = 0x16,
    VKEY_I = 0x17,
    VKEY_O = 0x18,
    VKEY_P = 0x19,
    VKEY_LEFT_BRACKET = 0x1A,  // [
    VKEY_RIGHT_BRACKET = 0x1B, // ]
    VKEY_ENTER = 0x1C,
    VKEY_LEFT_CTRL = 0x1D,
    VKEY_A = 0x1E,
    VKEY_S = 0x1F,
    VKEY_D = 0x20,
    VKEY_F = 0x21,
    VKEY_G = 0x22,
    VKEY_H = 0x23,
    VKEY_J = 0x24,
    VKEY_K = 0x25,
    VKEY_L = 0x26,
    VKEY_SEMICOLON = 0x27,   // ;
    VKEY_APOSTROPHE = 0x28,  // '
    VKEY_GRAVE = 0x29,       // `
    VKEY_LEFT_SHIFT = 0x2A,
    VKEY_BACKSLASH = 0x2B,   // 
    VKEY_Z = 0x2C,
    VKEY_X = 0x2D,
    VKEY_C = 0x2E,
    VKEY_V = 0x2F,
    VKEY_B = 0x30,
    VKEY_N = 0x31,
    VKEY_M = 0x32,
    VKEY_COMMA = 0x33,       // ,
    VKEY_PERIOD = 0x34,      // .
    VKEY_SLASH = 0x35,       // /
    VKEY_RIGHT_SHIFT = 0x36,
    VKEY_KP_MULTIPLY = 0x37, // Keypad *
    VKEY_LEFT_ALT = 0x38,
    VKEY_SPACE = 0x39,
    VKEY_CAPS_LOCK = 0x3A,
    VKEY_F1 = 0x3B,
    VKEY_F2 = 0x3C,
    VKEY_F3 = 0x3D,
    VKEY_F4 = 0x3E,
    VKEY_F5 = 0x3F,
    VKEY_F6 = 0x40,
    VKEY_F7 = 0x41,
    VKEY_F8 = 0x42,
    VKEY_F9 = 0x43,
    VKEY_F10 = 0x44,
    VKEY_NUM_LOCK = 0x45,
    VKEY_SCROLL_LOCK = 0x46,
    VKEY_KP_7 = 0x47,
    VKEY_KP_8 = 0x48,
    VKEY_KP_9 = 0x49,
    VKEY_KP_MINUS = 0x4A,
    VKEY_KP_4 = 0x4B,
    VKEY_KP_5 = 0x4C,
    VKEY_KP_6 = 0x4D,
    VKEY_KP_PLUS = 0x4E,
    VKEY_KP_1 = 0x4F,
    VKEY_KP_2 = 0x50,
    VKEY_KP_3 = 0x51,
    VKEY_KP_0 = 0x52,
    VKEY_KP_DECIMAL = 0x53,  // Keypad .
    
    VKEY_KP_ENTER = 0x01C,
    VKEY_RIGHT_CTRL = 0x01D,
    VKEY_KP_DIVIDE = 0x035, // Keypad /
    VKEY_RIGHT_ALT = 0x038, // AltGr
    VKEY_HOME = 0x047,
    VKEY_UP = 0x048,
    VKEY_PAGE_UP = 0x049,
    VKEY_LEFT = 0x04B,
    VKEY_RIGHT = 0x04D,
    VKEY_END = 0x04F,
    VKEY_DOWN = 0x050,
    VKEY_PAGE_DOWN = 0x051,
    VKEY_INSERT = 0x052,
    VKEY_DELETE = 0x053,
    VKEY_LEFT_WINDOWS = 0x05B,
    VKEY_RIGHT_WINDOWS = 0x05C,
    VKEY_APPLICATION = 0x05D,
    VKEY_MOUSE = 0x05E,
    
    VKEY_MOUSE_LB = 0x05F,
    VKEY_MOUSE_RB = 0x060,
    VKEY_MOUSE_MB = 0x061,
    VKEY_MOUSE_MW = 0x062,

    VKEY_KEYBOARD = 0x063,
    VKEY_MAX,
};

enum ButtonCode
{
    BCODE_GAMEPAD_DPAD_UP            = 0x0001,
    BCODE_GAMEPAD_DPAD_DOWN          = 0x0002,
    BCODE_GAMEPAD_DPAD_LEFT          = 0x0004,
    BCODE_GAMEPAD_DPAD_RIGHT         = 0x0008,
    BCODE_GAMEPAD_START              = 0x0010,
    BCODE_GAMEPAD_BACK               = 0x0020,
    BCODE_GAMEPAD_LEFT_THUMB         = 0x0040,
    BCODE_GAMEPAD_RIGHT_THUMB        = 0x0080,
    BCODE_GAMEPAD_LEFT_SHOULDER      = 0x0100,
    BCODE_GAMEPAD_RIGHT_SHOULDER     = 0x0200,
    BCODE_GAMEPAD_GUIDE              = 0x0400,
    BCODE_GAMEPAD_A                  = 0x1000,
    BCODE_GAMEPAD_B                  = 0x2000,
    BCODE_GAMEPAD_X                  = 0x4000,
    BCODE_GAMEPAD_Y                  = 0x8000,
    BCODE_LSTICK                     = 0x8001,
    BOCDE_RSTICK                     = 0x8002,
    BCODE_PASS,
};

enum ToggleMode {
    T_MODE_SINGLE_PRESS = 0,
    T_MODE_HOLD = 1,
    T_MODE_HOLD_UNTOGGLE = 2,
};

#endif