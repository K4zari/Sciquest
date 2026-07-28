# /// script
# requires-python = ">=3.11"
# dependencies = ["pillow>=11.0.0"]
# ///
"""Post-process Retro Diffusion outputs into game-ready Topic 9 sprites."""
from __future__ import annotations
import math, random
from collections import deque
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "artifacts" / "retro"
DST = ROOT / "graphics" / "topic_9_earth"
DST.mkdir(parents=True, exist_ok=True)


def load_rgba(p: Path) -> Image.Image:
    return Image.open(p).convert("RGBA")


def whitekey_if_opaque(img: Image.Image) -> Image.Image:
    """If remove_bg left the image fully opaque, key out near-white background."""
    alpha = img.split()[3]
    if alpha.getextrema()[0] > 250:  # fully opaque -> need to key white
        px = img.load()
        w, h = img.size
        for y in range(h):
            for x in range(w):
                r, g, b, a = px[x, y]
                if r > 238 and g > 238 and b > 238:
                    px[x, y] = (r, g, b, 0)
    return img


def trim(img: Image.Image, athresh: int = 16, pad: int = 1) -> Image.Image:
    alpha = img.split()[3]
    bbox = alpha.point(lambda a: 255 if a > athresh else 0).getbbox()
    if not bbox:
        return img
    l, t, r, b = bbox
    l = max(0, l - pad); t = max(0, t - pad)
    r = min(img.width, r + pad); b = min(img.height, b + pad)
    return img.crop((l, t, r, b))


def square(img: Image.Image) -> Image.Image:
    s = max(img.size)
    canvas = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    canvas.paste(img, ((s - img.width) // 2, (s - img.height) // 2), img)
    return canvas


# ---------- Moon phases ----------
def make_moon_phases() -> None:
    moon = whitekey_if_opaque(load_rgba(SRC / "moon" / "moon-output-01.png"))
    moon = square(trim(moon)).resize((128, 128), Image.LANCZOS)
    alpha = moon.split()[3]
    bbox = alpha.point(lambda a: 255 if a > 24 else 0).getbbox()
    cx = (bbox[0] + bbox[2]) / 2.0
    cy = (bbox[1] + bbox[3]) / 2.0
    rad = max(bbox[2] - bbox[0], bbox[3] - bbox[1]) / 2.0

    # New, Waxing Crescent, First Quarter, Waxing Gibbous, Full (lit grows from the right)
    a_vals = [1.0, 0.6, 0.0, -0.6, -1.0]
    sheet = Image.new("RGBA", (128 * 5, 128), (0, 0, 0, 0))
    for i, a in enumerate(a_vals):
        frame = moon.copy()
        px = frame.load()
        for y in range(128):
            ny = (y - cy) / rad
            half = math.sqrt(max(0.0, 1.0 - min(1.0, ny * ny)))
            xbound = a * half
            for x in range(128):
                r, g, b, al = px[x, y]
                if al < 16:
                    continue
                nx = (x - cx) / rad
                if nx <= xbound:  # unlit -> dim, cool tint, keep silhouette readable
                    px[x, y] = (int(r * 0.22), int(g * 0.24), int(b * 0.34), al)
        sheet.paste(frame, (128 * i, 0), frame)
    sheet.save(DST / "moon_phases.png")
    print("moon_phases.png", sheet.size)


# ---------- Connected-component extraction (planets) ----------
def components(img: Image.Image, athresh: int = 30, min_area: int = 80):
    w, h = img.size
    px = img.load()
    seen = [[False] * w for _ in range(h)]
    comps = []
    for sy in range(h):
        for sx in range(w):
            if seen[sy][sx] or px[sx, sy][3] <= athresh:
                continue
            q = deque([(sx, sy)])
            seen[sy][sx] = True
            pts = []
            while q:
                x, y = q.popleft()
                pts.append((x, y))
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < w and 0 <= ny < h and not seen[ny][nx] and px[nx, ny][3] > athresh:
                        seen[ny][nx] = True
                        q.append((nx, ny))
            if len(pts) >= min_area:
                xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
                comps.append((len(pts), (min(xs), min(ys), max(xs) + 1, max(ys) + 1)))
    comps.sort(reverse=True)
    return comps


def extract_planets() -> None:
    img = whitekey_if_opaque(load_rgba(SRC / "planet" / "planet-output-01.png"))
    comps = components(img, athresh=40, min_area=120)
    for idx, (_, bbox) in enumerate(comps[:4]):
        crop = trim(img.crop(bbox))
        crop.save(DST / f"planet_{idx + 1}.png")
        print(f"planet_{idx + 1}.png", crop.size)


# ---------- Simple prop trims ----------
def trim_save(name_in: str, sub: str, name_out: str) -> None:
    img = whitekey_if_opaque(load_rgba(SRC / sub / name_in))
    img = trim(img)
    img.save(DST / name_out)
    print(name_out, img.size)


# ---------- Procedural star field ----------
def make_stars() -> None:
    random.seed(99)
    w, h = 256, 128
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = img.load()
    for _ in range(70):
        x = random.randint(1, w - 2); y = random.randint(1, h - 2)
        b = random.randint(170, 255)
        a = random.randint(140, 255)
        px[x, y] = (b, b, 255, a)
        if random.random() < 0.5:  # twinkle cross
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                px[x + dx, y + dy] = (b, b, 255, a // 2)
    img.save(DST / "stars.png")
    print("stars.png", img.size)


if __name__ == "__main__":
    make_moon_phases()
    extract_planets()
    trim_save("telescope-output-01.png", "telescope", "telescope.png")
    trim_save("asteroid-output-01.png", "asteroid", "asteroid.png")
    trim_save("craterrock-output-01.png", "craterrock", "crater_rock.png")
    make_stars()
    print("done")
