from gui import *
from ui_interface import *

# if __name__ == "__main__":
#     app = Application()
#     gui: GUI = GUI()
#     gui.main_window.setWindowIcon(gui.icons["icon"])

#     gui.access_token = account.load_token()
#     account.login_user(gui)

#     gui.show()
#     app.start()

if __name__ == "__main__":
    # await_access_token()

    app = Application()
    gui: GUI = GUI()
    gui.main_window.setWindowIcon(gui.icons["icon"])

    gui.access_token = account.load_token()
    account.login_user(gui)

    gui.show()
    app.start()

    # on access token:
    # valide
    # if valid:
    #   save token and login
    # if not valid:
    #   show login screen with error