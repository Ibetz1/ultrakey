from flask import Flask, request, redirect
import requests
import os
import secrets
import time
from cachetools import TTLCache

app = Flask(__name__)

REDIRECT_URI = "https://ultrakey.onrender.com/callback"
SCOPE = "identify+guilds+guilds.members.read"
TOKEN_URL = "https://discord.com/api/oauth2/token"
CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
BASE_TTL = 120

temp_tokens = TTLCache(maxsize=1000, ttl=BASE_TTL)

def generate_token() -> str:
    temp_key = secrets.token_urlsafe(32)
    return temp_key

@app.route('/')
def index():
    return "<h1>Why are you here</h1>"

@app.route('/callback')
def callback():
    code = request.args.get("code")
    if not code:
        return "Missing code in redirect."

    data = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": REDIRECT_URI,
        "scope": SCOPE
    }
    headers = { "Content-Type": "application/x-www-form-urlencoded" }

    response = requests.post(TOKEN_URL, data=data, headers=headers)
    if response.status_code != 200:
        return f"Token request failed: {response.text}"

    tokens = response.json()
    access_token = tokens.get("access_token")

    if access_token:
        return redirect(f"http://localhost:49152?access_token={access_token}")
    else:
        return "Failed to retrieve access token."

@app.route('/getkey')
def getkey():
    code = request.args.get("code")
    if not code:
        return "Missing code in redirect."

    data = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": "http://localhost:5000/getkey", #REDIRECT_URI,
        "scope": SCOPE
    }
    headers = { "Content-Type": "application/x-www-form-urlencoded" }

    response = requests.post(TOKEN_URL, data=data, headers=headers)
    if response.status_code != 200:
        return f"Token request failed: {response.text}"

    tokens = response.json()
    access_token = tokens.get("access_token")
    url_token = secrets.token_urlsafe(32)
    temp_tokens[url_token] = access_token

    if access_token:
        return redirect(f"http://localhost:49152?access_token={url_token}")
    else:
        return "Failed to retrieve access token."

@app.route('/access')
def getaccess():
    url_token = request.args.get("access_token")
    if not url_token:
        return "Missing access_token", 400

    access_token = temp_tokens.get(url_token)
    if not access_token:
        return "Invalid or expired token", 403

    return { "access_token": access_token }

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)