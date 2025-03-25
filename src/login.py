import sys
from PyQt6.QtWidgets import QApplication, QMainWindow
from PyQt6.QtWebEngineWidgets import QWebEngineView
from PyQt6.QtWebEngineCore import QWebEngineSettings
from PyQt6.QtCore import QUrl
import urllib.parse
from urllib.parse import urlparse, parse_qs
import requests
import json
import os
from gui import *
from ui_interface import UltraKeyUI
import webbrowser

UKPLUS_ID = "1353625283286007839"
PREMIUM_ID = "1353625280111181856"
OWNER_ID = "1353186170724683924"
GUILD_ID = "1353186170711965836"
TOKEN_FILE = "access_token.json"

def save_token(token):
    with open(TOKEN_FILE, "w") as f:
        json.dump({"access_token": token}, f)

def load_token():
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE, "r") as f:
            return json.load(f).get("access_token")
    return None

def get_subscribed(role_id, access_token):
    url = f"https://discord.com/api/users/@me/guilds/{GUILD_ID}/member"

    headers = {
        "Authorization": f"Bearer {access_token}"
    }

    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        data = response.json()
        roles = data.get("roles", [])
        return roles
    else:
        print("Failed to get member info:", response.status_code, response.text)

    return []

def get_guilds(access_token):
    headers = {
        'Authorization': f'Bearer {access_token}'
    }

    response = requests.get('https://discord.com/api/users/@me/guilds', headers=headers)
    ret = []

    if response.status_code == 200:
        guilds = response.json()
        for guild in guilds:
            ret.append(guild["id"])
    else:
        print("Failed to fetch guilds:", response.status_code, response.text)

    return ret

def check_login_status(gui, roles, guilds):
    if GUILD_ID in guilds:
        print("found guild")
        if (PREMIUM_ID in roles and UKPLUS_ID in roles) or (OWNER_ID in roles):
            gui.set_window("emulator")
        else:
            gui.set_window("purchase")
    else:
        gui.set_window("purchase")
        
class DiscordLogin(QWebEngineView):
    def __init__(self, ui: GUI, redirect=None):
        super().__init__()
        self.gui = ui
        self.redirect = redirect
        self.load_ui()

    def load_ui(self):
        self.settings().setAttribute(QWebEngineSettings.WebAttribute.JavascriptEnabled, True)
        self.settings().setAttribute(QWebEngineSettings.WebAttribute.LocalStorageEnabled, True)
        self.settings().setAttribute(QWebEngineSettings.WebAttribute.PluginsEnabled, True)
        self.settings().setAttribute(QWebEngineSettings.WebAttribute.FullScreenSupportEnabled, True)
        self.page().profile().setHttpUserAgent(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        )

        # Discord OAuth2 settings
        client_id = '1353490529660309524'
        redirect_uri = urllib.parse.quote('http://localhost:5000/callback', safe='')
        scope = 'identify+guilds+guilds.members.read'
        response_type = 'token'

        auth_url = (
            f"https://discord.com/oauth2/authorize"
            f"?client_id={client_id}"
            f"&redirect_uri={redirect_uri}"
            f"&response_type={response_type}"
            f"&scope={scope}"
        )

        self.urlChanged.connect(self.on_url_changed)
        self.setUrl(QUrl(auth_url))

    def on_url_changed(self, url: QUrl):
        url = url.toString()

        if ("access_token" in url):
            parsed_url = urlparse(url)
            fragment = parsed_url.fragment
            params = parse_qs(fragment)
            access_token = params.get('access_token', [None])[0]
            guilds = get_guilds(access_token=access_token)
            roles = get_subscribed("", access_token=access_token)

            if callable(self.redirect):
                self.redirect(roles, guilds)

    def cleanup(self):
        try:
            self.urlChanged.disconnect()
        except TypeError:
            pass

        self.page().deleteLater()
        self.deleteLater()

class CredentialsWindow(BaseUI):
    def __init__(self, ui: GUI):
        super().__init__()
        self.gui = ui

        self.load_ui()

    def load_ui(self):
        self.add_widget(QLabel("Sign in with discord"))
        self.swap_button = self.add_widget(Button("Sign In", callback=self.open_login))

    def open_login(self, widget: Button):
        self.gui.set_window("browser")
        self.gui.main_window.setGeometry(QRect(0, 0, 800, 800))

class PurchaseWindow(BaseUI):
    def __init__(self, ui: GUI):
        super().__init__()
        self.gui = ui
        self.load_ui()

    def load_ui(self):
        self.add_widget(QLabel("Purchase Ultrakey"))
        self.swap_button = self.add_widget(Button("Purchase", callback=self.open_purchase))

    def open_purchase(self, widget: Button):
        webbrowser.open("https://discord.gg/4v9Pq6x23d")

if __name__ == "__main__":
    app = Application()
    gui: GUI = GUI()

    gui.cache_window("browser", DiscordLogin(gui, redirect=partial(check_login_status, gui)))
    gui.cache_window("login", CredentialsWindow(gui))
    gui.cache_window("emulator", UltraKeyUI(gui))
    gui.cache_window("purchase", PurchaseWindow(gui))

    gui.set_window("login")
    gui.show()
    app.start()