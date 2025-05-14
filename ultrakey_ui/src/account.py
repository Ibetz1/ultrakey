from bindings import *
import os
from assets import *
import requests
import assets
import ui_interface
import winreg
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
import base64

def get_hardware_id():
    key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE,
                         r"SOFTWARE\Microsoft\Cryptography")
    value, _ = winreg.QueryValueEx(key, "MachineGuid")
    return value.encode()

def derive_key(hardware_id, salt=b"c06005db-9d98-4bad-afe1-9bd0c8a2db7f", iterations=100000):
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=iterations,
    )
    return base64.urlsafe_b64encode(kdf.derive(hardware_id))

def del_token():
    with open(assets.TOKEN_FILE, "w") as f:
        f.write("")

def save_token(token):
    hardware_id = get_hardware_id()
    key = derive_key(hardware_id)
    fernet = Fernet(key)
    encrypted_token = fernet.encrypt(token.encode())
    with open(assets.TOKEN_FILE, "wb") as f:
        f.write(encrypted_token)

def load_token():
    if os.path.exists(assets.TOKEN_FILE):
        with open(assets.TOKEN_FILE, "rb") as f:
            encrypted_token = f.read()
        hardware_id = get_hardware_id()
        key = derive_key(hardware_id)
        fernet = Fernet(key)
        try:
            return fernet.decrypt(encrypted_token).decode()
        except Exception:
            return None
    return None

def get_subscribed(role_id, access_token):
    url = f"https://discord.com/api/users/@me/guilds/{assets.GUILD_ID}/member"

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

def is_token_valid(access_token):
    headers = {
        "Authorization": f"Bearer {access_token}"
    }

    response = requests.get("https://discord.com/api/users/@me", headers=headers)

    if response.status_code == 200:
        print("Token is valid.")
        return True
    else:
        print(f"Token is invalid. Status code: {response.status_code}")
        return False

def check_login_status(gui, access_token):
    print("checking login status")

    guilds = get_guilds(access_token=access_token)
    roles = get_subscribed("", access_token=access_token)

    if assets.GUILD_ID in guilds:
        print("found guild")

        valid = False
        if assets.PREMIUM_ID in roles: valid = True
        if assets.UKPLUS_ID in roles: valid = True
        if assets.OWNER_ID in roles: valid = True
        if assets.LIFETIME_ID in roles: valid = True
        if assets.GIFTED_ID in roles: valid = True
        if assets.REVOKED_ID in roles: valid = False

        if valid:
            gui.set_window(ui_interface.UltraKeyUI(gui))
        else:
            gui.set_window(ui_interface.PurchaseWindow(gui))
    else:
        gui.set_window(ui_interface.PurchaseWindow(gui))

def login_user(gui, err=None):
    print("logging in")

    if is_token_valid(gui.access_token):
        check_login_status(gui, gui.access_token)
    else:
        gui.set_window(ui_interface.CredentialsWindow(gui, err=err))

def logout_user(gui):
    del_token()
    gui.access_token = ""
    gui.set_window(ui_interface.CredentialsWindow(gui))