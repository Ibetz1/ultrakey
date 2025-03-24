# import discord
# from discord.ext import commands
# TOKEN = "MTM1MzQ5MDUyOTY2MDMwOTUyNA.GXmwhd.kSQULZYYhBi82rfZ-Bxp8-dBXP8wa6mMl8klyY"

# intents = discord.Intents.default()
# intents.message_content = True

# bot = commands.Bot(command_prefix='!', intents=intents)

# @bot.event
# async def on_ready():
#     print(f'Logged in as {bot.user}!')

# @bot.command()
# async def ping(ctx):
#     await ctx.send('Pong!')

# bot.run(TOKEN)

from flask import Flask, redirect, request, session, url_for
import os
import requests
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "some_random_secret")

CLIENT_ID = os.getenv("1353490529660309524")
CLIENT_SECRET = os.getenv("j21t154HUpiui2md1d7jS9wUg_-fwOhU")
REDIRECT_URI = os.getenv("https://ultrakey.onrender.com")  # Must match exactly in Discord Dev Portal
OAUTH_SCOPE = "identify email"

DISCORD_API_BASE = "https://discord.com/api"

@app.route("/")
def index():
    return '<a href="/login">Login with Discord</a>'

@app.route("/login")
def login():
    discord_auth_url = (
        f"{DISCORD_API_BASE}/oauth2/authorize"
        f"?client_id={CLIENT_ID}"
        f"&redirect_uri={REDIRECT_URI}"
        f"&response_type=code"
        f"&scope={OAUTH_SCOPE.replace(' ', '%20')}"
    )
    return redirect(discord_auth_url)

@app.route("/callback")
def callback():
    code = request.args.get("code")
    if not code:
        return "No code provided", 400

    data = {
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": REDIRECT_URI,
        "scope": OAUTH_SCOPE,
    }

    headers = {
        "Content-Type": "application/x-www-form-urlencoded"
    }

    # Exchange code for access token
    token_response = requests.post(f"{DISCORD_API_BASE}/oauth2/token", data=data, headers=headers)
    token_json = token_response.json()
    access_token = token_json.get("access_token")

    if not access_token:
        return f"Token exchange failed: {token_json}", 400

    # Use token to get user info
    user_response = requests.get(
        f"{DISCORD_API_BASE}/users/@me",
        headers={"Authorization": f"Bearer {access_token}"}
    )
    user = user_response.json()

    return f"Hello, {user['username']}#{user['discriminator']}!"

if __name__ == "__main__":
    app.run(debug=True)