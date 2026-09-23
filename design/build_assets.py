# Emits the Evaporate logo + icon set as SVG files.
# Run: python build_assets.py   (writes into ./assets)
import io, os

os.makedirs("assets/logo", exist_ok=True)
os.makedirs("assets/icons", exist_ok=True)

GRAD = ('<linearGradient id="g" x1="0" y1="1" x2="0" y2="0">'
        '<stop offset="0" stop-color="#C93A05"/>'
        '<stop offset=".52" stop-color="#FF7A18"/>'
        '<stop offset="1" stop-color="#FFC24D"/></linearGradient>')
GRAD2 = ('<linearGradient id="g2" x1="0" y1="1" x2="1" y2="0">'
         '<stop offset="0" stop-color="#7A2FD6"/>'
         '<stop offset=".5" stop-color="#FF7A18"/>'
         '<stop offset="1" stop-color="#5EE7FF"/></linearGradient>')

FLAME = ('M24 42c-7.2 0-12-4.3-12-10.3 0-5.3 3.8-8.9 7.2-13.4C22.1 14 24 9.4 24 5.8'
         'c0 3.6 1.9 8.2 4.8 12.5 3.4 4.5 7.2 8.1 7.2 13.4 0 6-4.8 10.3-12 10.3Z')
# Пробел в начале второй строки обязателен: Python склеивает строки как есть,
# и «-4.8» + «0» превращалось в одно число «-4.80». Браузер рисует контур до
# ошибки, а flutter_svg на ней не рисует ничего.
CORE = ('M24 36.6c-3 0-5-1.8-5-4.4 0-2.7 2.2-4.1 3.6-6.5.8-1.5 1.4-3.2 1.4-4.8'
        ' 0 1.6.6 3.3 1.4 4.8 1.4 2.4 3.6 3.8 3.6 6.5 0 2.6-2 4.4-5 4.4Z')
FLAME_T = ('M24 39c-6 0-10-3.6-10-8.6 0-4.4 3.2-7.4 6-11.2C22.4 15.8 24 12 24 9'
           'c0 3 1.6 6.8 4 10.2 2.8 3.8 6 6.8 6 11.2 0 5-4 8.6-10 8.6Z')
CORE_T = ('M24 34.5c-2.5 0-4.2-1.5-4.2-3.7 0-2.2 1.9-3.4 3-5.4.7-1.3 1.2-2.7 1.2-4'
          ' 0 1.3.5 2.7 1.2 4 1.1 2 3 3.2 3 5.4 0 2.2-1.7 3.7-4.2 3.7Z')

PLATE = ('<rect width="48" height="48" rx="14" fill="#0B0B12"/>'
         '<rect x=".5" y=".5" width="47" height="47" rx="13.5" fill="none" '
         'stroke="#FFFFFF" stroke-opacity=".1"/>')


def svg48(body):
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" '
            'width="48" height="48">' + body + '</svg>\n')


LOGOS = {}

# the mark alone, transparent — for placing inside an existing container
LOGOS["mark-a-vent"] = svg48(
    '<defs>' + GRAD + '</defs>'
    '<path d="' + FLAME + '" fill="url(#g)"/>'
    '<path d="' + CORE + '" fill="#fff" fill-opacity=".94"/>'
    '<circle cx="24" cy="3" r="1.8" fill="#FFC24D"/>'
    '<circle cx="16" cy="8.5" r="1.2" fill="#FFC24D" fill-opacity=".55"/>'
    '<circle cx="32.4" cy="9.6" r="1.1" fill="#FFC24D" fill-opacity=".45"/>')

# A — primary app icon
LOGOS["appicon-a-vent"] = svg48(
    '<defs>' + GRAD + '</defs>' + PLATE +
    '<path d="' + FLAME_T + '" fill="url(#g)"/>'
    '<path d="' + CORE_T + '" fill="#fff" fill-opacity=".92"/>'
    '<circle cx="24" cy="7" r="1.5" fill="#FFC24D"/>'
    '<circle cx="18.5" cy="11.5" r="1" fill="#FFC24D" fill-opacity=".55"/>'
    '<circle cx="29.5" cy="12.5" r=".9" fill="#FFC24D" fill-opacity=".45"/>')

# B — prism: one beam in, a spectrum out
LOGOS["appicon-b-prism"] = svg48(
    '<defs>' + GRAD2 + '</defs>' + PLATE +
    '<path d="M24 9 39 35H9L24 9Z" fill="none" stroke="url(#g2)" stroke-width="2.4" '
    'stroke-linejoin="round"/>'
    '<path d="M9 29h10" stroke="#fff" stroke-width="2.4" stroke-linecap="round"/>'
    '<path d="M26.5 27h13" stroke="#FF4D5E" stroke-width="2" stroke-linecap="round"/>'
    '<path d="M26.5 31h13" stroke="#FFC24D" stroke-width="2" stroke-linecap="round"/>'
    '<path d="M26.5 35h13" stroke="#5EE7FF" stroke-width="2" stroke-linecap="round"/>')

# C — the droplet coming apart, bottom to top
LOGOS["appicon-c-phase"] = svg48(
    '<defs>' + GRAD + '</defs>' + PLATE +
    '<path d="M24 41c-5.8 0-10-3.9-10-9.1 0-4.9 4.9-8.9 7.3-13.6h5.4C29.1 23 34 27 34 '
    '31.9 34 37.1 29.8 41 24 41Z" fill="url(#g)"/>'
    '<rect x="20.8" y="14" width="6.4" height="2.4" rx="1.2" fill="#FFC24D" fill-opacity=".9"/>'
    '<rect x="21.9" y="9.8" width="4.2" height="2.2" rx="1.1" fill="#FFC24D" fill-opacity=".62"/>'
    '<rect x="22.8" y="6.2" width="2.4" height="2" rx="1" fill="#FFC24D" fill-opacity=".38"/>'
    '<circle cx="24" cy="32" r="4.2" fill="#fff" fill-opacity=".9"/>')

# D — reduced to a core; survives at 16 px and in a tray
LOGOS["appicon-d-core"] = svg48(
    '<defs>' + GRAD + '</defs>' + PLATE +
    '<circle cx="24" cy="24" r="14" fill="none" stroke="url(#g)" stroke-width="3"/>'
    '<circle cx="24" cy="24" r="18.5" fill="none" stroke="#FF7A18" stroke-opacity=".5" '
    'stroke-width="1" stroke-dasharray="2 6"/>'
    '<circle cx="24" cy="24" r="9.4" fill="#FFC24D" fill-opacity=".26"/>'
    '<circle cx="24" cy="24" r="6.2" fill="#fff"/>')

# the only permitted single-colour reductions
LOGOS["mark-mono-light"] = svg48('<path d="' + FLAME + '" fill="#F2F3F7"/>')
LOGOS["mark-mono-dark"] = svg48('<path d="' + FLAME + '" fill="#0B0B12"/>')

# favicon — variant D reads best at 16 px
LOGOS["favicon"] = svg48(
    '<defs>' + GRAD + '</defs>'
    '<rect width="48" height="48" rx="10" fill="#0B0B12"/>'
    '<circle cx="24" cy="24" r="15" fill="none" stroke="url(#g)" stroke-width="4"/>'
    '<circle cx="24" cy="24" r="7" fill="#fff"/>')

# horizontal lockup — clear space on every side equals the core height
LOGOS["lockup-horizontal"] = (
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 64" width="300" height="64">'
    '<defs>' + GRAD +
    '<linearGradient id="gw" x1="0" y1="0" x2="1" y2="0">'
    '<stop offset=".34" stop-color="#F2F3F7"/>'
    '<stop offset=".76" stop-color="#FFC24D"/>'
    '<stop offset="1" stop-color="#FF7A18"/></linearGradient></defs>'
    '<g transform="translate(8,8)">'
    '<rect width="48" height="48" rx="14" fill="#0B0B12"/>'
    '<path d="' + FLAME_T + '" fill="url(#g)"/>'
    '<path d="' + CORE_T + '" fill="#fff" fill-opacity=".92"/></g>'
    '<text x="72" y="40" fill="url(#gw)" '
    'font-family="Unbounded, Onest, system-ui, sans-serif" font-size="25" '
    'font-weight="800" letter-spacing="1.2">EVAPORATE</text>'
    '<text x="73" y="53" fill="#6E7387" font-family="JetBrains Mono, monospace" '
    'font-size="7" letter-spacing="3.4">GAME LAUNCHER</text>'
    '</svg>\n')

# same lockup on its own dark plate, for decks and readmes where the page is light
LOGOS["lockup-horizontal-plate"] = LOGOS["lockup-horizontal"].replace(
    'height="64">', 'height="64"><rect width="300" height="64" rx="16" fill="#06060A"/>', 1)

for name, data in LOGOS.items():
    io.open("assets/logo/" + name + ".svg", "w", encoding="utf-8").write(data)

# ── icon set: stroke geometry on a 24 grid, 1.5 px, round caps ───────────
HEAD = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" '
        'height="24" fill="none" stroke="currentColor" stroke-width="1.5" '
        'stroke-linecap="round" stroke-linejoin="round">')
HEAD_F = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" '
          'height="24" fill="currentColor">')


def stroke(body):
    return HEAD + body + '</svg>\n'


def solid(body):
    return HEAD_F + body + '</svg>\n'


ICONS = {
    "library": stroke('<rect x="3" y="4" width="7" height="16" rx="1.6"/>'
                      '<rect x="13" y="4" width="8" height="7" rx="1.6"/>'
                      '<rect x="13" y="14" width="8" height="6" rx="1.6"/>'),
    "download": stroke('<path d="M12 3v11"/><path d="M8 10.5 12 14.5 16 10.5"/>'
                       '<path d="M4 17.5c2.2 1.6 4.8 2.5 8 2.5s5.8-.9 8-2.5"/>'),
    "saves": stroke('<ellipse cx="12" cy="7" rx="7.5" ry="3.2"/>'
                    '<path d="M4.5 7v10c0 1.8 3.4 3.2 7.5 3.2s7.5-1.4 7.5-3.2V7"/>'
                    '<path d="M4.5 12.2c0 1.8 3.4 3.2 7.5 3.2s7.5-1.4 7.5-3.2"/>'),
    "settings": stroke('<circle cx="12" cy="12" r="8.2"/><circle cx="12" cy="12" r="3"/>'
                       '<path d="M12 3.8v4.1M12 16.1v4.1M3.8 12h4.1M16.1 12h4.1"/>'),
    "friends": stroke('<circle cx="9" cy="9.5" r="3.4"/><circle cx="16.5" cy="11" r="2.4"/>'
                      '<path d="M3.4 19.5c.5-3.2 2.9-5 5.6-5s5.1 1.8 5.6 5"/>'
                      '<path d="M17 16.4c2 .5 3.3 1.8 3.6 3.1"/>'),
    "search": stroke('<circle cx="11" cy="11" r="6.2"/><path d="M15.6 15.6 20 20"/>'
                     '<path d="M11 6.4v1.6M11 14v1.6M6.4 11h1.6M14 11h1.6"/>'),
    "play": solid('<path d="M7.5 4.8a1 1 0 0 1 1.52-.85l10.2 6.35a1 1 0 0 1 0 1.7L9.02 '
                  '18.35a1 1 0 0 1-1.52-.85V4.8Z"/>'),
    "pause": solid('<rect x="7" y="5" width="3.6" height="14" rx="1.2"/>'
                   '<rect x="13.4" y="5" width="3.6" height="14" rx="1.2"/>'),
    "close": stroke('<path d="M6 6l12 12M18 6 6 18"/>'),
    "go": stroke('<path d="M5 12h13M12.5 6l6 6-6 6"/>'),
    "info": stroke('<circle cx="12" cy="12" r="8.4"/><path d="M12 11v5.2M12 7.8v.4"/>'),
    "peers": stroke('<circle cx="12" cy="12" r="2.2"/><circle cx="4.4" cy="6.5" r="1.7"/>'
                    '<circle cx="19.6" cy="6.5" r="1.7"/><circle cx="4.4" cy="17.5" r="1.7"/>'
                    '<circle cx="19.6" cy="17.5" r="1.7"/>'
                    '<path d="m6 7.6 4.2 3.1M18 7.6l-4.2 3.1M6 16.4l4.2-3.1M18 16.4l-4.2-3.1"/>'),
    "seed": stroke('<path d="M12 20V9"/>'
                   '<path d="M12 9c0-3.4 2.6-5.6 6.4-5.6C18.4 7.4 15.6 9.4 12 9Z"/>'
                   '<path d="M12 13.4C9.2 13.4 7 11.8 7 8.6c2.8 0 5 1.6 5 4.8Z"/>'),
    "speed": stroke('<path d="M4.2 17.6a9 9 0 1 1 15.6 0"/><path d="m12 13 4.2-4.2"/>'
                    '<circle cx="12" cy="13" r="1.3" fill="currentColor" stroke="none"/>'),
    "disk": stroke('<circle cx="12" cy="12" r="8.4"/><circle cx="12" cy="12" r="2.4"/>'
                   '<path d="M12 3.6v3.2"/>'),
    "cloud": stroke('<path d="M7 18.5a4 4 0 0 1-.5-7.97 5.2 5.2 0 0 1 10.05-1.2A3.9 3.9 '
                    '0 0 1 17.6 18.5H7Z"/>'),
    "folder": stroke('<path d="M3.2 6.4A1.8 1.8 0 0 1 5 4.6h3.6l1.8 2.2H19a1.8 1.8 0 0 1 '
                     '1.8 1.8v8.8a1.8 1.8 0 0 1-1.8 1.8H5a1.8 1.8 0 0 1-1.8-1.8V6.4Z"/>'),
    "trophy": stroke('<path d="M7.5 4h9v5.2a4.5 4.5 0 0 1-9 0V4Z"/>'
                     '<path d="M7.5 5.6H5.2a2.6 2.6 0 0 0 2.4 3.5M16.5 5.6h2.3a2.6 2.6 0 '
                     '0 1-2.4 3.5"/><path d="M12 13.7V17M9 20h6"/>'),
    "verified": stroke('<path d="M12 3.2 19.4 6v6.2c0 4.3-3 7.2-7.4 8.6-4.4-1.4-7.4-4.3-7.4'
                       '-8.6V6L12 3.2Z"/><path d="m9 12.2 2.2 2.2L15.2 10"/>'),
    "boost": stroke('<path d="M13.4 2.8 5.6 13.4h5.2l-.6 7.8 7.8-10.6h-5.2l.6-7.8Z"/>'),
    "audio": stroke('<path d="M4.5 9.4h3.1L12 5.6v12.8l-4.4-3.8H4.5V9.4Z"/>'
                    '<path d="M15.4 9.6a3.4 3.4 0 0 1 0 4.8M18 7a7 7 0 0 1 0 10"/>'),
    "desktop": stroke('<rect x="2.6" y="4.5" width="18.8" height="12" rx="1.8"/>'
                      '<path d="M8.5 20h7M12 16.5V20"/>'),
    "laptop": stroke('<rect x="4.5" y="5" width="15" height="10" rx="1.6"/>'
                     '<path d="M2 18.5h20"/>'),
    "alert": stroke('<path d="M12 4.4 21 19.6H3L12 4.4Z"/>'
                    '<path d="M12 10.2v4M12 17.1v.3"/>'),
    "drive": stroke('<rect x="2.8" y="12.4" width="18.4" height="7.4" rx="2"/>'
                    '<path d="M5.4 4.4h13.2l2.6 8H2.8l2.6-8Z"/>'
                    '<path d="M6.4 16.2h.3M9.6 16.2h.3"/>'),
    "power": stroke('<path d="M12 3.4v8"/>'
                    '<path d="M7.2 6.6a7.6 7.6 0 1 0 9.6 0"/>'),
    # Магнит: magnet-ссылка вместо файла .torrent.
    "magnet": stroke('<path d="M5.4 4.2v7.6a6.6 6.6 0 0 0 13.2 0V4.2h-4.4v7.6a2.2 2.2 0 '
                     '0 1-4.4 0V4.2H5.4Z"/>'
                     '<path d="M5.4 8.6h4.4M14.2 8.6h4.4"/>'),
    # Записка: написать другу.
    "note": stroke('<path d="M5 4.6h14v14.8H5V4.6Z"/>'
                   '<path d="M8.4 9h7.2M8.4 12.6h7.2M8.4 16.2h4"/>'),
    # Галочка: выбрать эту версию.
    "check": stroke('<path d="m5 12.6 4.6 4.6L19 6.8"/>'),
    # Слияние: две ветки сохранения разошлись и сходятся обратно.
    "merge": stroke('<path d="M6.5 3.6v5.2c0 2.6 2 4.4 5.5 4.4s5.5 1.8 5.5 4.4v2.8"/>'
                    '<path d="m3.6 6.4 2.9-2.9 2.9 2.9"/>'
                    '<path d="m14.6 17.6 2.9 2.9 2.9-2.9"/>'
                    '<path d="M17.5 3.6v4.8"/>'),
    # Сети нет: перечёркнутая антенна.
    "wifi-off": stroke('<path d="M3 3.6 21 20.4"/>'
                       '<path d="M2.4 8.6a15 15 0 0 1 5.2-3.1M13 4.6a15 15 0 0 1 8.6 4"/>'
                       '<path d="M5.8 12.2a10.5 10.5 0 0 1 3-1.8M15.6 10.8a10.5 10.5 0 '
                       '0 1 2.6 1.4"/>'
                       '<path d="M9.2 15.7a5.6 5.6 0 0 1 4.6.3"/><path d="M12 19.3v.3"/>'),
    # Повтор: перекачать части, проверить связь.
    "retry": stroke('<path d="M20 12a8 8 0 1 1-2.6-5.9"/><path d="M20.4 3.6v4.8h-4.8"/>'),
}

for name, data in ICONS.items():
    io.open("assets/icons/" + name + ".svg", "w", encoding="utf-8").write(data)

print("logos:", len(LOGOS), "icons:", len(ICONS))
