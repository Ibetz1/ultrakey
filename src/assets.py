from PyQt6.QtGui import QIcon, QPixmap
import os

ASSETS_DIR = "./assets/"

asset_files = {
    "a-filled.png": "a",
    "b-filled.png": "b",
    "x-filled.png": "x",
    "y-filled.png": "y",
    "dpad-down.png": "dpad_down",
    "dpad-left.png": "dpad_left",
    "dpad-right.png": "dpad_right",
    "dpad-up.png": "dpad_up",
    "dpad.png": "dpad",
    "left-bumper.png": "left_bumper",
    "left-trigger.png": "left_trigger",
    "left-joystick-all.png": "left_joystick_all",
    "left-joystick-down.png": "left_joystick_down",
    "left-joystick-left.png": "left_joystick_left",
    "left-joystick-press.png": "left_joystick_press",
    "left-joystick-right.png": "left_joystick_right",
    "left-joystick-up.png": "left_joystick_up",
    "left-joystick.png": "left_joystick",
    "left-stick.png": "left_stick",
    "menu.png": "menu",
    "right-bumper.png": "right_bumper",
    "right-trigger.png": "right_trigger",
    "right-joystick-all.png": "right_joystick_all",
    "right-joystick-down.png": "right_joystick_down",
    "right-joystick-left.png": "right_joystick_left",
    "right-joystick-press.png": "right_joystick_press",
    "right-joystick-right.png": "right_joystick_right",
    "right-joystick-up.png": "right_joystick_up",
    "right-joystick.png": "right_joystick",
    "right-stick.png": "right_stick",
    "view.png": "view",
    "controller-img.png": "roller_graphic",
    "switch.png": "switch",
    "hold.png": "hold",
    "bind.png": "bind",
    "keyboard.png": "keyboard",
    "icon.ico": "icon",
}

main_theme = """
    QComboBox {
        background-color: transparent;  /* Blue background */
        color: white;
        border: 1px solid transparent;
        border-bottom: 1.5px solid #757575; /* Underline effect at the bottom */
        padding: 5px;
    }

    QComboBox:hover {
        background-color: transparent;
        color: white;
        border: 1px solid transparent;
        padding: 5px;
        border-top-left-radius: 10px;
        border-top-right-radius: 10px;
        border-bottom: 1.5px solid #2980b9;
    }

    /* Dropdown button */
    QComboBox::drop-down {
        background-color: transparent;
        width: 45px;
        border: none;
    }

    /* Keep the arrow visible */
    QComboBox::down-arrow {
        image: url(assets/expand.png);  /* Replace with an actual arrow image */
        width: 17px;
        height: 17px;
    }

    QGroupBox {
        border: 1.5px solid #303030;
        margin-top: 20px; /* Pushes the title down */
        border-radius: 10px;
    }

    /* Title style */
    QGroupBox:title {
        subcontrol-origin: margin;
        subcontrol-position: top left;
        padding: 11px;
    }

    QPushButton {
        background-color: transparent;
        color: white;
        border: 1.5px solid #757575;
        border-radius: 14px;
        padding: 5px 5px;
    }

    QPushButton:hover {
        background-color: #252525;
        border: 1.5px solid #34C6F4;
    }

    QPushButton:disabled {
        color: #303030;
        background-color: #0B0B0B;
        border: 1.5px solid #F15B22;
    }

    QLineEdit {
        background-color: #171717;
        color: white;
        border-radius: 7px;
        border-bottom: 1.5px solid #757575;
        padding: 5px;
    }

    QLineEdit:hover {
        background-color: #252525;
        border-bottom: 1.5px solid #34C6F4;
    }

    QLineEdit:focus {
        border: 1.5px solid #34C6F4;
        background-color: transparent;
    }

    QLineEdit:disabled {
        color: #303030;
        border-bottom: 1.5px solid #F15B22;
        background-color: #0B0B0B;
    }

    QSlider {
        background: transparent;
    }

    QSlider::groove:horizontal {
        background: #0A0A0A;  /* Light gray */
        height: 4px;
        border-radius: 2px;
    }

    QSlider::handle:horizontal {
        background: #34C6F4;  /* Red */
        border: none;
        width: 12px;  /* Increase size for better visibility */
        height: 12px;
        margin: -4px 0;  /* Ensures it aligns properly with the track */
        border-radius: 6px;  /* Half of width & height for a perfect circle */
    }

    QSlider::sub-page:horizontal {
        background-color: #34C6F4;       /* Blue progress bar */
    }


"""

input_theme = """
QLineEdit {
    background-color: #ecf0f1;  /* Light gray */
    color: #2c3e50;
    border: 2px solid #3498db;
    border-radius: 8px;
    padding: 5px;
}

QLineEdit:hover {
    border: 2px solid #2980b9;  /* Darker blue on hover */
}

QLineEdit:focus {
    border: 2px solid #e67e22;  /* Orange border when focused */
    background-color: white;
}

QLineEdit:disabled {
    background-color: #bdc3c7;
    color: #7f8c8d;
    border: 2px solid #95a5a6;
}

QLineEdit:read-only {
    background-color: #f7f7f7;
    color: #7f8c8d;
    border: 2px dashed #bdc3c7;
}

QLineEdit:selected {
    background-color: #f39c12; /* Orange highlight */
    color: black;
}

/* Placeholder text */
QLineEdit::placeholder {
    color: #95a5a6;
    font-style: italic;
}

/* Clear button (X) */
QLineEdit::clear-button {
    image: url(clear_icon.png); /* Custom clear icon */
    width: 14px;
    height: 14px;
}

/* Selection highlight */
QLineEdit::selection {
    background-color: #e74c3c;
    color: white;
}
"""

def load_icons():
    icons = {}
    for filename, key in asset_files.items():
        path = os.path.join(ASSETS_DIR, filename)
        icons[key] = QIcon(path)

    return icons;

def load_pix_maps():
    pixmaps = {}
    for filename, key in asset_files.items():
        path = os.path.join(ASSETS_DIR, filename)
        pixmaps[key] = QPixmap(path)

    return pixmaps;

lua_template = """function main()
    -- this gets repeated every frame, enjoy :)
end
"""