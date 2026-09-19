import discord
from discord.ext import commands
import sqlite3
import secrets
import threading
from flask import Flask, request, jsonify

# ═══════════════════════════════════════════
# AYARLAR
# ═══════════════════════════════════════════
DISCORD_TOKEN = "MTU1MDk4OTQxNzY0Mjk5MTczOA.GRnVvC.3A9QzWpjXz9HGXVlbtIM6Ec1zZ0oy2gqPjkBIs"   # ← kendi token'ını koy
API_SECRET = "ramhub_gizli_2024"      # ← Roblox script'inde de aynısı olacak

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

    # Kanaldaki mesajı sil
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

    # Kanala "DM'ni kontrol et" mesajı at (5 sn sonra silinsin)
    try:
        await ctx.send(
            f"{ctx.author.mention} 📩 **DM kutunu kontrol et!**",
            delete_after=5
        )
    except:
        pass

    # DM gönder
    try:
        await ctx.author.send(dm_msg)
    except discord.Forbidden:
        # DM kapalıysa kanala geçici mesaj
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
    app.run(host="0.0.0.0", port=8080, debug=False, use_reloader=False)

# ═══════════════════════════════════════════
# BAŞLAT
# ═══════════════════════════════════════════
if __name__ == "__main__":
    threading.Thread(target=run_api, daemon=True).start()
    print("🌐 API: http://0.0.0.0:8080")
    bot.run(DISCORD_TOKEN)
