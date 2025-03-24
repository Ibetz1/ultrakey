import discord
from discord.ext import commands
TOKEN = "MTM1MzQ5MDUyOTY2MDMwOTUyNA.GXmwhd.kSQULZYYhBi82rfZ-Bxp8-dBXP8wa6mMl8klyY"

intents = discord.Intents.default()
intents.message_content = True

bot = commands.Bot(command_prefix='!', intents=intents)

@bot.event
async def on_ready():
    print(f'Logged in as {bot.user}!')

@bot.command()
async def ping(ctx):
    await ctx.send('Pong!')

bot.run(TOKEN)