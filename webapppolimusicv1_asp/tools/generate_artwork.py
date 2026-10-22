"""Generate the missing artwork referenced by BDD_PoliMusic.sql (Aegean / Cycladic palette)."""
import math, os, random
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.abspath(__file__))
A = os.path.join(ROOT, "assets")

NAVY = (18, 41, 66)
DEEP = (16, 58, 92)
BLUE = (31, 92, 139)
SKY = (108, 165, 199)
PALE = (200, 224, 236)
CREAM = (250, 247, 240)
SAFFRON = (242, 183, 5)
ORANGE = (217, 108, 44)
TERRA = (184, 78, 42)
OLIVE = (122, 128, 82)


def font(size, bold=False):
    for name in (("georgiab.ttf" if bold else "georgia.ttf"), "times.ttf", "segoeui.ttf"):
        p = os.path.join("C:\\Windows\\Fonts", name)
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                pass
    return ImageFont.load_default()


def vgrad(size, top, bottom):
    w, h = size
    base = Image.new("RGB", (1, h))
    d = ImageDraw.Draw(base)
    for y in range(h):
        t = y / max(h - 1, 1)
        t = t ** 0.92
        d.point((0, y), tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    return base.resize((w, h), Image.BILINEAR)


def grain(img, amount=9):
    w, h = img.size
    n = Image.effect_noise((w, h), 26).convert("L")
    overlay = Image.merge("RGB", (n, n, n))
    return Image.blend(img, Image.blend(img, overlay, 0.16), amount / 40.0)


def meander(draw, x, y, w, h, color, lw=3, reps=None):
    """Greek key band."""
    unit = h
    reps = reps or max(1, int(w // (unit * 1.6)))
    step = w / reps
    for i in range(reps):
        x0 = x + i * step
        draw.line([(x0, y + h), (x0, y), (x0 + step * 0.62, y),
                   (x0 + step * 0.62, y + h * 0.62), (x0 + step * 0.26, y + h * 0.62),
                   (x0 + step * 0.26, y + h * 0.26)], fill=color, width=lw)


def cover(idx, top, bottom, disc, motif, seed):
    random.seed(seed)
    S = 800
    img = vgrad((S, S), top, bottom).convert("RGB")
    d = ImageDraw.Draw(img, "RGBA")

    if motif == "waves":
        for i in range(11):
            yy = 470 + i * 32
            amp = 14 + i * 2.2
            pts = [(x, yy + math.sin(x / 58.0 + i * 0.55) * amp) for x in range(0, S + 8, 8)]
            d.line(pts, fill=(CREAM[0], CREAM[1], CREAM[2], 40 + i * 9), width=3)
        d.ellipse([S * 0.28, S * 0.10, S * 0.72, S * 0.54], fill=disc + (238,))
        d.ellipse([S * 0.28, S * 0.10, S * 0.72, S * 0.54], outline=CREAM + (110,), width=3)

    elif motif == "rays":
        cx, cy = S * 0.5, S * 0.47
        for i in range(28):
            a = i * (2 * math.pi / 28)
            r1, r2 = S * 0.235, S * 0.40 + (26 if i % 2 else 0)
            d.line([(cx + math.cos(a) * r1, cy + math.sin(a) * r1),
                    (cx + math.cos(a) * r2, cy + math.sin(a) * r2)],
                   fill=disc + (150,), width=7)
        d.ellipse([cx - S * 0.235, cy - S * 0.235, cx + S * 0.235, cy + S * 0.235], fill=disc + (255,))
        d.ellipse([cx - S * 0.16, cy - S * 0.16, cx + S * 0.16, cy + S * 0.16], fill=top + (255,))

    elif motif == "rings":
        cx, cy = S * 0.5, S * 0.5
        for i in range(9):
            r = S * 0.10 + i * S * 0.045
            d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=disc + (200 - i * 16,), width=5)
        d.ellipse([cx - S * 0.075, cy - S * 0.075, cx + S * 0.075, cy + S * 0.075], fill=disc + (255,))
        d.line([(0, cy), (S, cy)], fill=CREAM + (55,), width=2)

    elif motif == "hills":
        for i, col in enumerate([disc, ORANGE, TERRA]):
            yy = 430 + i * 78
            pts = [(x, yy - math.sin((x / S) * math.pi * (1.4 + i * 0.3)) * (110 - i * 22)) for x in range(0, S + 10, 10)]
            d.polygon(pts + [(S, S), (0, S)], fill=col + (205 - i * 30,))
        d.ellipse([S * 0.60, S * 0.13, S * 0.86, S * 0.39], fill=CREAM + (225,))

    else:  # meander
        d.rectangle([S * 0.10, S * 0.10, S * 0.90, S * 0.90], outline=disc + (230,), width=4)
        d.rectangle([S * 0.135, S * 0.135, S * 0.865, S * 0.865], outline=CREAM + (70,), width=2)
        d.ellipse([S * 0.34, S * 0.30, S * 0.66, S * 0.62], fill=disc + (240,))
        d.ellipse([S * 0.415, S * 0.375, S * 0.585, S * 0.545], fill=top + (255,))

    # meander band
    meander(d, 0, S - 74, S, 40, CREAM + (170,), lw=3)
    d.line([(0, S - 92), (S, S - 92)], fill=CREAM + (60,), width=2)
    d.line([(0, S - 26), (S, S - 26)], fill=CREAM + (60,), width=2)

    # sun tint glow
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([-S * 0.2, S * 0.35, S * 0.75, S * 1.3], fill=SAFFRON + (26,))
    glow = glow.filter(ImageFilter.GaussianBlur(70))
    img = Image.alpha_composite(img.convert("RGBA"), glow).convert("RGB")
    return grain(img, 7)


def avatar(size, top, bottom, accent, letter, seed):
    random.seed(seed)
    img = vgrad((size, size), top, bottom).convert("RGB")
    d = ImageDraw.Draw(img, "RGBA")
    c = size / 2.0
    # laurel wreath (symmetric, both branches)
    for a0, a1 in ((100, 252), (80, -72)):
        for i in range(7):
            a = math.radians(a0 + (a1 - a0) * i / 6.0)
            r = size * 0.345
            cx, cy = c + math.cos(a) * r, c - math.sin(a) * r
            rx, ry = size * 0.026, size * 0.058
            d.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=accent + (205,))
    d.ellipse([size * 0.14, size * 0.14, size * 0.86, size * 0.86], outline=accent + (110,), width=max(2, size // 200))
    f = font(int(size * 0.34), bold=True)
    bbox = d.textbbox((0, 0), letter, font=f)
    d.text((c - (bbox[2] - bbox[0]) / 2 - bbox[0], c - (bbox[3] - bbox[1]) / 2 - bbox[1] - size * 0.01),
           letter, font=f, fill=CREAM + (245,))
    return grain(img, 5)


def main():
    covers = [
        ("album1.png", DEEP, NAVY, ORANGE, "rays"),
        ("album2.png", SKY, BLUE, SAFFRON, "waves"),
        ("album3.png", SAFFRON, ORANGE, NAVY, "rings"),
        ("album4.png", CREAM, PALE, NAVY, "meander"),
        ("album5.png", NAVY, DEEP, SAFFRON, "hills"),
        ("default.png", DEEP, NAVY, PALE, "meander"),
    ]
    os.makedirs(os.path.join(A, "albumImages"), exist_ok=True)
    for i, (name, t, b, disc, motif) in enumerate(covers):
        cover(i, t, b, disc, motif, 1000 + i).save(os.path.join(A, "albumImages", name))

    artists = [
        ("artist1.jpg", DEEP, NAVY, SAFFRON, "J"),
        ("artist2.jpg", BLUE, DEEP, PALE, "A"),
        ("artist3.jpg", TERRA, ORANGE, CREAM, "M"),
        ("artist4.jpg", NAVY, (10, 24, 40), SAFFRON, "E"),
        ("artist5.jpg", SKY, BLUE, CREAM, "E"),
        ("default.png", BLUE, DEEP, PALE, "\u266a"),
    ]
    os.makedirs(os.path.join(A, "artistImages"), exist_ok=True)
    for i, (name, t, b, acc, letter) in enumerate(artists):
        avatar(700, t, b, acc, letter, 2000 + i).save(os.path.join(A, "artistImages", name), quality=92)

    os.makedirs(os.path.join(A, "userImages"), exist_ok=True)
    avatar(500, BLUE, DEEP, SAFFRON, "U", 3001).save(os.path.join(A, "userImages", "username1.png"))
    print("generated", sum(len(f) for _, _, f in os.walk(A)))


if __name__ == "__main__":
    main()
