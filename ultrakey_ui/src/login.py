from gui import *
from ui_interface import *
import account

if __name__ == "__main__":
    app = Application()
    gui: GUI = GUI()

    gui.access_token = account.load_token()
    account.login_user(gui)

    gui.show()
    app.start()