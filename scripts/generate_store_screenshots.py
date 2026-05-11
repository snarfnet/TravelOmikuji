from pathlib import Path
import math
import textwrap

from PIL import Image, ImageDraw, ImageFont, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
OUT = Path(r"C:\Users\Windows\travelomikuji_screenshots")
ICON = ROOT / "TravelOmikuji" / "Assets.xcassets" / "AppIcon.appiconset" / "appicon.png"

FONT_REG = r"C:\Windows\Fonts\NotoSansJP-VF.ttf"
FONT_BOLD = r"C:\Windows\Fonts\YuGothB.ttc"

SIZES = {
    "iphone_67": (1290, 2796),
    "iphone_65": (1242, 2688),
    "iphone_55": (1242, 2208),
    "ipad_129": (2048, 2732),
}


def font(size, bold=False):
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REG, size)


def lerp(a, b, t):
    return int(a + (b - a) * t)


def gradient(size, colors):
    w, h = size
    img = Image.new("RGB", size)
    pix = img.load()
    for y in range(h):
        t = y / max(1, h - 1)
        if t < 0.5:
            u = t / 0.5
            c0, c1 = colors[0], colors[1]
        else:
            u = (t - 0.5) / 0.5
            c0, c1 = colors[1], colors[2]
        c = tuple(lerp(c0[i], c1[i], u) for i in range(3))
        for x in range(w):
            pix[x, y] = c
    return img


def round_rect(draw, xy, r, fill, outline=None, width=1):
    draw.rounded_rectangle(xy, radius=r, fill=fill, outline=outline, width=width)


def text(draw, xy, value, size, fill, bold=False, anchor=None, align="left", spacing=8):
    draw.multiline_text(xy, value, font=font(size, bold), fill=fill, anchor=anchor, align=align, spacing=spacing)


def wrap(value, count):
    return "\n".join(textwrap.wrap(value, count))


def add_shadow_card(base, xy, r, fill, shadow=(80, 55, 30, 45), offset=18, blur=26, outline=(255, 255, 255, 150)):
    x1, y1, x2, y2 = xy
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle((x1, y1 + offset, x2, y2 + offset), radius=r, fill=shadow)
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(layer)
    d = ImageDraw.Draw(base)
    d.rounded_rectangle(xy, radius=r, fill=fill, outline=outline, width=max(2, int((x2 - x1) * 0.002)))


def add_status(draw, w, scale):
    s = scale
    text(draw, (int(72 * s), int(72 * s)), "9:41", int(42 * s), (42, 35, 28), True)
    x = w - int(250 * s)
    y = int(80 * s)
    for i in range(4):
        draw.rounded_rectangle((x + i * int(26 * s), y, x + i * int(26 * s) + int(13 * s), y + int(13 * s)), radius=int(5 * s), fill=(65, 57, 48, 160))
    draw.arc((w - int(165 * s), int(72 * s), w - int(110 * s), int(122 * s)), 210, 330, fill=(42, 35, 28), width=int(6 * s))
    draw.rounded_rectangle((w - int(94 * s), int(72 * s), w - int(28 * s), int(106 * s)), radius=int(12 * s), outline=(42, 35, 28), width=int(5 * s))
    draw.rounded_rectangle((w - int(86 * s), int(80 * s), w - int(38 * s), int(98 * s)), radius=int(7 * s), fill=(42, 35, 28))


def decorate_background(img, scale):
    w, h = img.size
    d = ImageDraw.Draw(img, "RGBA")
    s = scale
    for cx, cy, rr, color in [
        (w * 0.86, h * 0.09, 280 * s, (255, 255, 255, 58)),
        (w * 0.13, h * 0.25, 210 * s, (255, 255, 255, 52)),
        (w * 0.82, h * 0.83, 260 * s, (14, 165, 233, 30)),
    ]:
        d.ellipse((cx - rr, cy - rr, cx + rr, cy + rr), fill=color)
    for i in range(18):
        x = int((i * 179 + 90) % w)
        y = int((i * 317 + 160) % h)
        r = int((10 + i % 5 * 4) * s)
        d.polygon([(x, y - r), (x + r, y), (x, y + r), (x - r, y)], fill=(255, 255, 255, 55))


def paste_icon(img, x, y, size):
    if not ICON.exists():
        return
    icon = Image.open(ICON).convert("RGBA").resize((size, size), Image.LANCZOS)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size, size), radius=int(size * 0.24), fill=255)
    img.paste(icon, (x, y), mask)


def draw_ticket(draw, cx, cy, w, h, angle, fill, scale):
    ticket = Image.new("RGBA", (int(w * 1.5), int(h * 1.5)), (0, 0, 0, 0))
    td = ImageDraw.Draw(ticket, "RGBA")
    ox, oy = ticket.size[0] // 2 - w // 2, ticket.size[1] // 2 - h // 2
    td.rounded_rectangle((ox, oy, ox + w, oy + h), radius=int(14 * scale), fill=fill)
    td.ellipse((ox + w * 0.36, oy + h * 0.1, ox + w * 0.64, oy + h * 0.1 + w * 0.28), fill=(249, 115, 22))
    text(td, (ox + w // 2, oy + h // 2), "旅", int(34 * scale), (156, 52, 18), True, anchor="mm")
    rot = ticket.rotate(angle, resample=Image.Resampling.BICUBIC, expand=True)
    return rot, (int(cx - rot.size[0] / 2), int(cy - rot.size[1] / 2))


def omikuji_box(img, center, scale):
    d = ImageDraw.Draw(img, "RGBA")
    cx, cy = center
    s = scale
    for i in range(7):
        rot, pos = draw_ticket(d, int(cx + (i - 3) * 42 * s), int(cy - 170 * s - abs(i - 3) * 8 * s), int(52 * s), int(208 * s), (i - 3) * 8, [(255, 255, 255), (255, 241, 242), (236, 254, 255), (254, 243, 199)][i % 4], s)
        img.alpha_composite(rot, pos)
    x1, y1 = int(cx - 190 * s), int(cy - 95 * s)
    x2, y2 = int(cx + 190 * s), int(cy + 205 * s)
    d.rounded_rectangle((x1, y1, x2, y2), radius=int(42 * s), fill=(239, 68, 68), outline=(255, 255, 255, 120), width=int(3 * s))
    d.rounded_rectangle((x1 + int(42 * s), y1 + int(48 * s), x2 - int(42 * s), y1 + int(146 * s)), radius=int(24 * s), fill=(255, 255, 255, 50))
    text(d, (cx, y1 + int(88 * s)), "旅みくじ", int(46 * s), (255, 255, 255), True, anchor="mm")
    text(d, (cx, y1 + int(165 * s)), "TAP / SHAKE", int(22 * s), (255, 246, 222), True, anchor="mm")


def mini_landscape(draw, xy, scale, variant=0):
    x1, y1, x2, y2 = xy
    draw.rounded_rectangle(xy, radius=int(28 * scale), fill=(131, 207, 232))
    draw.rectangle((x1, int(y1 + (y2 - y1) * 0.54), x2, y2), fill=(52, 168, 83))
    draw.polygon([(x1, y2), (x1 + (x2 - x1) * 0.36, y1 + (y2 - y1) * 0.3), (x1 + (x2 - x1) * 0.67, y2)], fill=(76, 128, 92))
    draw.polygon([(x1 + (x2 - x1) * 0.28, y2), (x1 + (x2 - x1) * 0.62, y1 + (y2 - y1) * 0.2), (x2, y2)], fill=(44, 118, 93))
    draw.ellipse((x2 - int(115 * scale), y1 + int(42 * scale), x2 - int(38 * scale), y1 + int(119 * scale)), fill=(255, 225, 106))
    if variant == 1:
        draw.rectangle((x1, int(y1 + (y2 - y1) * 0.68), x2, y2), fill=(50, 154, 204))
    if variant == 2:
        for i in range(6):
            px = x1 + int((60 + i * 96) * scale)
            py = y2 - int(90 * scale)
            draw.rectangle((px, py, px + int(45 * scale), y2), fill=(126, 80, 54))
            draw.polygon([(px - int(18 * scale), py), (px + int(22 * scale), py - int(44 * scale)), (px + int(64 * scale), py)], fill=(244, 174, 82))


def bottom_tab(draw, w, h, scale, active=0):
    s = scale
    y = h - int(190 * s)
    draw.rounded_rectangle((0, y, w, h), radius=int(38 * s), fill=(255, 255, 255, 235))
    labels = [("旅みくじ", "✦"), ("結果", "◇"), ("リスト", "✓")]
    for i, (label, icon) in enumerate(labels):
        x = int(w * (i + 0.5) / 3)
        color = (194, 65, 12) if i == active else (139, 116, 92)
        text(draw, (x, y + int(58 * s)), icon, int(38 * s), color, True, anchor="mm")
        text(draw, (x, y + int(112 * s)), label, int(22 * s), color, True, anchor="mm")


def screen_home(size):
    w, h = size
    s = min(w / 1290, h / 2796)
    img = gradient(size, [(255, 248, 173), (255, 211, 165), (173, 232, 244)]).convert("RGBA")
    decorate_background(img, s)
    d = ImageDraw.Draw(img, "RGBA")
    add_status(d, w, s)
    paste_icon(img, int(72 * s), int(155 * s), int(112 * s))
    text(d, (int(210 * s), int(168 * s)), "トラベルおみくじ", int(39 * s), (54, 37, 26), True)
    text(d, (int(72 * s), int(310 * s)), "次の旅先を、\nおみくじで決めよう。", int(78 * s), (55, 38, 27), True, spacing=int(10 * s))
    text(d, (int(76 * s), int(545 * s)), "スマホを振るか、くじ箱をタップ。\nあなたに合う日本のまちを一枚で案内します。", int(34 * s), (122, 85, 54), True, spacing=int(12 * s))
    omikuji_box(img, (w // 2, int(1030 * s)), s)
    add_shadow_card(img, (int(92 * s), int(1375 * s), w - int(92 * s), int(1615 * s)), int(34 * s), (255, 255, 255, 215))
    text(d, (w // 2, int(1432 * s)), "今日の旅運", int(30 * s), (130, 84, 45), True, anchor="mm")
    text(d, (w // 2, int(1502 * s)), "大吉  知らない街で、いい寄り道に出会う日。", int(34 * s), (49, 37, 30), True, anchor="mm")
    chips = [("温泉", (14, 165, 233)), ("海街", (34, 197, 94)), ("レトロ商店街", (249, 115, 22))]
    x = int(92 * s)
    for label, color in chips:
        cw = int((250 + len(label) * 22) * s)
        d.rounded_rectangle((x, int(1700 * s), x + cw, int(1790 * s)), radius=int(45 * s), fill=(*color, 230))
        text(d, (x + cw // 2, int(1745 * s)), label, int(28 * s), (255, 255, 255), True, anchor="mm")
        x += cw + int(24 * s)
    mini_landscape(d, (int(92 * s), int(1875 * s), w - int(92 * s), h - int(310 * s)), s, 2)
    bottom_tab(d, w, h, s, 0)
    return img


def screen_result(size):
    w, h = size
    s = min(w / 1290, h / 2796)
    img = gradient(size, [(255, 244, 214), (255, 216, 168), (190, 235, 246)]).convert("RGBA")
    decorate_background(img, s)
    d = ImageDraw.Draw(img, "RGBA")
    add_status(d, w, s)
    text(d, (int(72 * s), int(170 * s)), "今日の旅先", int(42 * s), (122, 85, 54), True)
    text(d, (int(72 * s), int(240 * s)), "金沢", int(112 * s), (53, 38, 28), True)
    d.rounded_rectangle((int(900 * s), int(238 * s), int(1190 * s), int(320 * s)), radius=int(41 * s), fill=(239, 68, 68))
    text(d, (int(1045 * s), int(280 * s)), "大吉", int(34 * s), (255, 255, 255), True, anchor="mm")
    add_shadow_card(img, (int(72 * s), int(405 * s), w - int(72 * s), int(1090 * s)), int(48 * s), (255, 255, 255, 235))
    mini_landscape(d, (int(105 * s), int(440 * s), w - int(105 * s), int(850 * s)), s, 0)
    text(d, (int(115 * s), int(910 * s)), "城下町の路地を歩いて、\n甘いものと工芸に出会う旅。", int(45 * s), (52, 38, 28), True, spacing=int(12 * s))
    sections = [
        ("名物", "治部煮・金箔ソフト・和菓子", (249, 115, 22)),
        ("おすすめ", "ひがし茶屋街、兼六園、近江町市場", (225, 29, 72)),
        ("アクセス", "金沢駅からバスで中心部へ", (2, 132, 199)),
    ]
    y = int(1160 * s)
    for title, body, color in sections:
        add_shadow_card(img, (int(72 * s), y, w - int(72 * s), y + int(230 * s)), int(32 * s), (255, 255, 255, 225), blur=int(16 * s), offset=int(10 * s))
        d.rounded_rectangle((int(105 * s), y + int(52 * s), int(185 * s), y + int(132 * s)), radius=int(22 * s), fill=(*color, 35))
        text(d, (int(145 * s), y + int(92 * s)), "◆", int(30 * s), color, True, anchor="mm")
        text(d, (int(215 * s), y + int(48 * s)), title, int(29 * s), (130, 90, 58), True)
        text(d, (int(215 * s), y + int(100 * s)), body, int(36 * s), (50, 37, 28), True)
        y += int(260 * s)
    d.rounded_rectangle((int(110 * s), h - int(430 * s), w - int(110 * s), h - int(315 * s)), radius=int(34 * s), fill=(249, 115, 22))
    text(d, (w // 2, h - int(372 * s)), "行きたいリストに保存", int(34 * s), (255, 255, 255), True, anchor="mm")
    bottom_tab(d, w, h, s, 1)
    return img


def screen_saved(size):
    w, h = size
    s = min(w / 1290, h / 2796)
    img = gradient(size, [(255, 247, 173), (253, 230, 138), (186, 230, 253)]).convert("RGBA")
    decorate_background(img, s)
    d = ImageDraw.Draw(img, "RGBA")
    add_status(d, w, s)
    text(d, (int(72 * s), int(185 * s)), "行きたい旅リスト", int(70 * s), (54, 38, 28), True)
    text(d, (int(76 * s), int(300 * s)), "引いた旅先を保存して、次の休日の候補に。", int(34 * s), (122, 85, 54), True)
    add_shadow_card(img, (int(72 * s), int(415 * s), w - int(72 * s), int(760 * s)), int(42 * s), (255, 255, 255, 220))
    text(d, (int(125 * s), int(480 * s)), "週末のおすすめルート", int(34 * s), (130, 84, 45), True)
    draw_route(d, (int(155 * s), int(625 * s)), (w - int(155 * s), int(625 * s)), s)
    towns = [
        ("小樽", "北海道 / 運河とガラス工芸", "吉"),
        ("松本", "長野 / 城下町と喫茶店", "大吉"),
        ("由布院", "大分 / 温泉と朝霧", "中吉"),
        ("宮島", "広島 / 海に浮かぶ神社", "吉"),
    ]
    y = int(850 * s)
    for i, (name, detail, luck) in enumerate(towns):
        add_shadow_card(img, (int(72 * s), y, w - int(72 * s), y + int(205 * s)), int(34 * s), (255, 255, 255, 225), blur=int(14 * s), offset=int(9 * s))
        color = [(14, 165, 233), (249, 115, 22), (34, 197, 94), (225, 29, 72)][i]
        d.rounded_rectangle((int(110 * s), y + int(38 * s), int(235 * s), y + int(163 * s)), radius=int(28 * s), fill=(*color, 230))
        text(d, (int(172 * s), y + int(101 * s)), "旅", int(44 * s), (255, 255, 255), True, anchor="mm")
        text(d, (int(270 * s), y + int(48 * s)), name, int(43 * s), (52, 37, 28), True)
        text(d, (int(270 * s), y + int(112 * s)), detail, int(28 * s), (122, 85, 54), True)
        d.rounded_rectangle((w - int(245 * s), y + int(68 * s), w - int(110 * s), y + int(125 * s)), radius=int(28 * s), fill=(*color, 230))
        text(d, (w - int(177 * s), y + int(96 * s)), luck, int(23 * s), (255, 255, 255), True, anchor="mm")
        y += int(230 * s)
    add_shadow_card(img, (int(72 * s), h - int(620 * s), w - int(72 * s), h - int(315 * s)), int(42 * s), (255, 255, 255, 205))
    text(d, (int(130 * s), h - int(550 * s)), "旅のきっかけを、\n楽しくストック。", int(54 * s), (53, 38, 28), True, spacing=int(12 * s))
    text(d, (int(130 * s), h - int(405 * s)), "気になった街を残しておけば、予定を立てる日も迷いません。", int(30 * s), (122, 85, 54), True)
    bottom_tab(d, w, h, s, 2)
    return img


def draw_route(draw, start, end, scale):
    sx, sy = start
    ex, ey = end
    points = []
    for i in range(100):
        t = i / 99
        x = sx + (ex - sx) * t
        y = sy + math.sin(t * math.pi * 3) * 38 * scale
        points.append((x, y))
    draw.line(points, fill=(249, 115, 22), width=int(8 * scale), joint="curve")
    for t in [0, 0.33, 0.66, 1]:
        x = sx + (ex - sx) * t
        y = sy + math.sin(t * math.pi * 3) * 38 * scale
        draw.ellipse((x - 22 * scale, y - 22 * scale, x + 22 * scale, y + 22 * scale), fill=(255, 255, 255), outline=(249, 115, 22), width=int(7 * scale))


def resize_cover(img, size):
    src_w, src_h = img.size
    dst_w, dst_h = size
    scale = max(dst_w / src_w, dst_h / src_h)
    new = img.resize((int(src_w * scale), int(src_h * scale)), Image.LANCZOS)
    left = (new.size[0] - dst_w) // 2
    top = (new.size[1] - dst_h) // 2
    return new.crop((left, top, left + dst_w, top + dst_h))


def save_set(name, size):
    folder = OUT / name
    folder.mkdir(parents=True, exist_ok=True)
    screens = [screen_home(size), screen_result(size), screen_saved(size)]
    for idx, img in enumerate(screens, 1):
        img.convert("RGB").save(folder / f"travelomikuji_{idx:02d}.png", quality=95)


def make_preview():
    srcs = [Image.open(OUT / "iphone_67" / f"travelomikuji_{i:02d}.png").convert("RGB") for i in range(1, 4)]
    thumbs = [im.resize((300, int(300 * im.height / im.width)), Image.LANCZOS) for im in srcs]
    w = sum(im.width for im in thumbs) + 80
    h = max(im.height for im in thumbs) + 50
    preview = Image.new("RGB", (w, h), (245, 239, 226))
    x = 20
    for im in thumbs:
        preview.paste(im, (x, 25))
        x += im.width + 20
    preview.save(OUT / "preview_contact_sheet.png", quality=95)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, size in SIZES.items():
        save_set(name, size)
    make_preview()
    print(f"saved: {OUT}")


if __name__ == "__main__":
    main()
