# backend.py
from flask import Flask, request, redirect
import requests
import threading

app = Flask(__name__)

CLIENT_ID = "1353490529660309524"
CLIENT_SECRET = "j21t154HUpiui2md1d7jS9wUg_-fwOhU"
REDIRECT_URI = "http://localhost:5000/callback"
TOKEN_URL = "https://discord.com/api/oauth2/token"
USER_URL = "https://discord.com/api/users/@me"
logged_in_user = None

@app.route("/")
def index():
    return "Discord Login Backend Running"

@app.route("/callback")
def callback():
    global logged_in_user
    code = request.args.get("code")
    if not code:
        return "No code provided", 400

    data = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": REDIRECT_URI,
    }

    headers = {
        "Content-Type": "application/x-www-form-urlencoded"
    }

    r = requests.post(TOKEN_URL, data=data, headers=headers)
    if r.status_code != 200:
        return f"Failed to get token: {r.text}", 400

    access_token = r.json()["access_token"]
    user_res = requests.get(USER_URL, headers={"Authorization": f"Bearer {access_token}"})
    user_data = user_res.json()
    logged_in_user = user_data
    return "<h1>Login successful, you can close this tab.</h1>"

@app.route("/status")
def status():
    return {
        "logged_in": logged_in_user is not None,
        "user": logged_in_user
    }

if __name__ == "__main__":
    print(f"Starting backend server on http://localhost:5000")
    app.run(port=5000)