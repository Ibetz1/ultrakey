from gui import *
from ui_interface import *

if __name__ == "__main__":
    app = Application()
    gui: GUI = GUI()
    gui.main_window.setWindowIcon(gui.icons["icon"])

    gui.access_token = account.load_token()
    account.login_user(gui)
    # gui.set_window(UltraKeyUI(gui))

    gui.show()
    app.start()