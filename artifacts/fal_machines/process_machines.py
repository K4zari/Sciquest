# /// script
# requires-python = ">=3.11"
# dependencies = ["pillow>=11.0.0"]
# ///
"""Post-process fal.ai outputs into Topic 10 (Machines) game assets."""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "artifacts" / "fal_machines"
DST = ROOT / "graphics" / "topic_10_machines"
DST.mkdir(parents=True, exist_ok=True)


def make_tileset() -> None:
    img = Image.open(SRC / "tileset" / "tileset-output-01.png").convert("RGBA")
    # Square-crop centre, then downscale to a 256x256 (8x8 of 32px) atlas.
    s = min(img.size)
    left = (img.width - s) // 2
    top = (img.height - s) // 2
    img = img.crop((left, top, left + s, top + s))
    sheet = img.resize((256, 256), Image.LANCZOS)
    sheet.save(DST / "machines_tileset.png")
    print("machines_tileset.png", sheet.size)


def make_background() -> None:
    img = Image.open(SRC / "bg" / "factory_bg-output-01.png").convert("RGBA")
    # Resize to a manageable parallax width while keeping the 16:9 framing.
    target_w = 960
    target_h = round(img.height * target_w / img.width)
    bg = img.resize((target_w, target_h), Image.LANCZOS)
    bg.save(DST / "factory_bg.png")
    print("factory_bg.png", bg.size)

    # A dimmer, cooler far copy for a second parallax layer (depth haze).
    far = ImageEnhance.Brightness(bg).enhance(0.6)
    far = ImageEnhance.Color(far).enhance(0.7)
    far.save(DST / "factory_bg_far.png")
    print("factory_bg_far.png", far.size)


if __name__ == "__main__":
    make_tileset()
    make_background()
    print("done")
