from PyQt6.QtGui import QIcon, QPixmap
import os
import sys

REDIRECT_URI = "https://ultrakey.onrender.com/callback"
UKPLUS_ID = "1366679702567260180"
PREMIUM_ID = "1353625280111181856"
OWNER_ID = "1353186170724683924"
GIFTED_ID = "1354086033108762624"
GUILD_ID = "1353186170711965836"
REVOKED_ID = "1366878376262107288"
LIFETIME_ID = "1366877501481160807"
TOKEN_FILE = "login.key"
ASSETS_DIR = "./assets/"

LUA_TEMPLATE = """
function main()
    -- this repeats forever :)
end
"""

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
    "uksignin.png": "signin",
    "value.png": "value",
}

main_theme = """
    #Window {
        background-color: #080808;
    }

    #Title { 
        font-size: 18px; 
    }

    #ErrMessage { 
        color: #F15B22;
        font-size: 18px;
        font-weight: bold;
    }

    #Flagged {
        background-color: #F15B22;
        color: black;
        border: 1.5px solid transparent;
        border-radius: 14px;
        font-weight: bold;
        padding: 5px 5px;
        font-size: 13px;
    }

    #Flagged:hover {
        color: white;
        background-color: #991717;
    }

    QTabWidget::pane {
        background: transparent; /* Background of the tab widget */
        border: 1px solid transparent;
    }
    QTabBar::tab {
        background: #171717;
        color: white;
        padding: 5px;
        font-size: 14px; 
        border-radius: 5px;
        margin-right: 10px;
    }

    QScrollArea > QWidget > QWidget { 
        background: #0D0D0D;
    }
    
    QTabBar::tab:selected {
        background: #252525; /* Background of selected tab */
    }

    QLabel {
        font-size: 14px;
    }

    QComboBox {
        background-color: transparent;
        color: white;
        border: 1px solid transparent;
        border-bottom: 1.5px solid #757575;
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
        background-color: #0D0D0D;
        border: 1.5px solid transparent;
        margin-top: 20px; /* Pushes the title down */
        border-radius: 15px;
        padding: 30px 11px 11px 11px; /* Top padding for title inside the box */
        font-size: 16px;
    }

    QGroupBox:title {
        subcontrol-origin: padding;
        subcontrol-position: top center;
        padding-top: 8px;
        color: white;
        font-weight: bold;
        background: transparent; /* optional: no background behind title */
    }

    QPushButton {
        background-color: #38C6F3;
        color: black;
        border: 1.5px solid transparent;
        border-radius: 14px;
        font-weight: bold;
        padding: 5px 5px;
        font-size: 13px;
    }

    QPushButton:hover {
        color: white;
        background-color: #1E6A82;
    }

    QPushButton:disabled {
        color: #303030;
        background-color: #F15B22;
        border: 1.5px solid transparent;
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
        background-color: #34C6F4;
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

def read_file(file):
    with open(file, 'r', encoding='utf-8') as file:
        return file.read().encode("utf-8")

lua_template = """function main()
    -- this gets repeated every frame, enjoy :)
end
"""