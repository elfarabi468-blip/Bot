import discord
from discord.ext import commands
import sqlite3
import secrets
import threading
import os
from flask import Flask, request, jsonify

# ═══════════════════════════════════════════
# AYARLAR (Panelden okunur)
# ═══════════════════════════════════════════
DISCORD_TOKEN = os.environ.get("DISCORD_TOKEN", "")
API_SECRET = os.environ.get("API_SECRET", "ramhub_gizli_2024")

if not DISCORD_TOKEN:
    print("❌ DISCORD_TOKEN ayarlanmamış!")
    exit(1)

# ═══════════════════════════════════════════
# VERİTABANI
# ═══════════════════════════════════════════
conn = sqlite3.connect("keys.db", check_same_thread=False)
c = conn.cursor()
c.execute("""
    CREATE TABLE IF NOT EXISTS keys (
        discord_id TEXT PRIMARY KEY,
        username TEXT,
        key TEXT UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
""")
conn.commit()

def get_key_by_user(discord_id):
    c.execute("SELECT key FROM keys WHERE discord_id = ?", (discord_id,))
    row = c.fetchone()
    return row[0] if row else None

def create_key(discord_id, username):
    new_key = "RAM-" + secrets.token_hex(8).upper()
    try:
        c.execute(
            "INSERT INTO keys (discord_id, username, key) VALUES (?, ?, ?)",
            (discord_id, username, new_key)
        )
        conn.commit()
    except sqlite3.IntegrityError:
        return get_key_by_user(discord_id)
    return new_key

def is_valid_key(key):
    c.execute("SELECT discord_id FROM keys WHERE key = ?", (key,))
    return c.fetchone() is not None

# ═══════════════════════════════════════════
# DISCORD BOT
# ═══════════════════════════════════════════
intents = discord.Intents.default()
intents.message_content = True
intents.members = True

bot = commands.Bot(command_prefix=".", intents=intents, help_command=None)

@bot.event
async def on_ready():
    print(f"✅ Bot hazır: {bot.user}")
    print(f"📡 Sunucular: {len(bot.guilds)}")

@bot.command(name="key")
async def key_cmd(ctx):
    user_id = str(ctx.author.id)
    username = str(ctx.author)

    try:
        await ctx.message.delete()
    except:
        pass

    existing = get_key_by_user(user_id)

    if existing:
        key_value = existing
        dm_msg = (
            f"🔑 **Kayıtlı Key'in**\n"
            f"```{key_value}```\n"
            f"Bunu Roblox script'ine gir."
        )
    else:
        key_value = create_key(user_id, username)
        dm_msg = (
            f"🔑 **Yeni Key Oluşturuldu**\n"
            f"```{key_value}```\n"
            f"Bunu Roblox script'ine gir.\n"
            f"Tekrar `.key` yazarsan aynı key'i alırsın."
        )

    try:
        await ctx.send(
            f"{ctx.author.mention} 📩 **DM kutunu kontrol et!**",
            delete_after=5
        )
    except:
        pass

    try:
        await ctx.author.send(dm_msg)
    except discord.Forbidden:
        await ctx.send(
            f"{ctx.author.mention} ⚠️ DM kutun kapalı! Özelden yazamıyorum.",
            delete_after=8
        )

# ═══════════════════════════════════════════
# FLASK API (Roblox doğrulama)
# ═══════════════════════════════════════════
app = Flask(__name__)

@app.route("/", methods=["GET"])
def home():
    return "RamHub Key API çalışıyor ✅"

@app.route("/verify", methods=["POST"])
def verify():
    try:
        data = request.get_json()
    except:
        return jsonify({"valid": False, "message": "Geçersiz istek"}), 400

    if data.get("secret") != API_SECRET:
        return jsonify({"valid": False, "message": "Yetkisiz"}), 403

    key = str(data.get("key", "")).strip()
    if not key:
        return jsonify({"valid": False, "message": "Key boş"})

    if is_valid_key(key):
        return jsonify({"valid": True, "message": "Key geçerli"})
    return jsonify({"valid": False, "message": "Key geçersiz"})

def run_api():
    # ⚠️ ÖNEMLİ: Bot-Hosting SERVER_PORT kullanıyor
    port = int(os.environ.get("SERVER_PORT", 8080))
    app.run(host="0.0.0.0", port=port, debug=False, use_reloader=False)

# ═══════════════════════════════════════════
# BAŞLAT
# ═══════════════════════════════════════════
if __name__ == "__main__":
    threading.Thread(target=run_api, daemon=True).start()
    print("🌐 API başlatıldı")
    bot.run(DISCORD_TOKEN)
