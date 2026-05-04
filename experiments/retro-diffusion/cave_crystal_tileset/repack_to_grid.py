"""Re-pack RD-generated cave tilesets onto a clean 32x32 grid for Godot.

v1 (cave_crystal_tileset.png) — no gutters, slice as fixed 32x32 grid.
v2 (cave_crystal_tileset_edges.png) — irregular gutters, find connected
components above an off-white threshold, crop each, fit-into-32x32, pack
into a fresh sheet with transparent background.
"""
from __future__ import annotations

from pathlib import Path
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[3]
SRC = ROOT / "graphics/tilesets"
OUT = ROOT / "graphics/tilesets"
TILE = 32
COLS = 8
BG_THRESHOLD = 235  # pixel is background if R,G,B all >= this
MIN_COMPONENT = 64  # ignore components smaller than this many pixels


def near_white_to_alpha(rgb: np.ndarray) -> np.ndarray:
    """Return RGBA where near-white pixels are transparent."""
    h, w, _ = rgb.shape
    out = np.zeros((h, w, 4), dtype=np.uint8)
    out[..., :3] = rgb
    is_bg = (rgb >= BG_THRESHOLD).all(axis=-1)
    out[..., 3] = np.where(is_bg, 0, 255)
    return out


def repack_v1_strict_grid(src_path: Path, out_path: Path) -> None:
    """v1 has regular gutters (10px horizontal, 14px vertical) but the
    std-based gutter check missed them. Use the same connected-component
    extraction as v2 — tiles do not actually touch."""
    img = Image.open(src_path).convert("RGB")
    rgb = np.array(img)
    rgba = near_white_to_alpha(rgb)
    mask = rgba[..., 3] > 0
    boxes = connected_components(mask)
    print(f"v1: found {len(boxes)} components")

    n = len(boxes)
    cols = COLS
    rows = (n + cols - 1) // cols
    sheet = np.zeros((rows * TILE, cols * TILE, 4), dtype=np.uint8)
    boxes.sort(key=lambda b: (b[1] // 8, b[0]))
    for i, (xmin, ymin, xmax, ymax) in enumerate(boxes):
        crop = rgba[ymin:ymax, xmin:xmax]
        tile = fit_into_tile(crop)
        gy, gx = divmod(i, cols)
        sheet[gy * TILE:(gy + 1) * TILE, gx * TILE:(gx + 1) * TILE] = tile
    Image.fromarray(sheet, mode="RGBA").save(out_path)
    print(f"v1: wrote {out_path.name} ({sheet.shape[1]}x{sheet.shape[0]})  "
          f"grid {cols}x{rows} @ {TILE}px")


def connected_components(mask: np.ndarray) -> list[tuple[int, int, int, int]]:
    """Return list of (xmin, ymin, xmax, ymax) bounding boxes for 4-connected
    foreground regions in `mask` (bool array). Iterative flood fill."""
    h, w = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    boxes = []
    for sy in range(h):
        for sx in range(w):
            if not mask[sy, sx] or visited[sy, sx]:
                continue
            stack = [(sy, sx)]
            xmin, ymin, xmax, ymax = sx, sy, sx, sy
            count = 0
            while stack:
                y, x = stack.pop()
                if y < 0 or y >= h or x < 0 or x >= w:
                    continue
                if visited[y, x] or not mask[y, x]:
                    continue
                visited[y, x] = True
                count += 1
                xmin = min(xmin, x); xmax = max(xmax, x)
                ymin = min(ymin, y); ymax = max(ymax, y)
                stack.append((y + 1, x))
                stack.append((y - 1, x))
                stack.append((y, x + 1))
                stack.append((y, x - 1))
            if count >= MIN_COMPONENT:
                boxes.append((xmin, ymin, xmax + 1, ymax + 1))
    return boxes


def fit_into_tile(crop_rgba: np.ndarray, tile: int = TILE) -> np.ndarray:
    """Force-fit a crop to exactly tile×tile via NEAREST resize.
    Always fills the cell — no transparent padding, no gaps between adjacent
    placed tiles. Aspect ratio may distort slightly, but RD components are
    already close to square so the visual impact is minimal."""
    img = Image.fromarray(crop_rgba, mode="RGBA").resize(
        (tile, tile), Image.NEAREST
    )
    return np.array(img)


def repack_v2_components(src_path: Path, out_path: Path) -> None:
    img = Image.open(src_path).convert("RGB")
    rgb = np.array(img)
    rgba = near_white_to_alpha(rgb)
    mask = rgba[..., 3] > 0
    boxes = connected_components(mask)
    print(f"v2: found {len(boxes)} components")

    n = len(boxes)
    cols = COLS
    rows = (n + cols - 1) // cols
    sheet = np.zeros((rows * TILE, cols * TILE, 4), dtype=np.uint8)

    # Sort boxes by (top, left) so layout reads naturally
    boxes.sort(key=lambda b: (b[1] // 8, b[0]))

    for i, (xmin, ymin, xmax, ymax) in enumerate(boxes):
        crop = rgba[ymin:ymax, xmin:xmax]
        tile = fit_into_tile(crop)
        gy, gx = divmod(i, cols)
        sheet[gy * TILE:(gy + 1) * TILE, gx * TILE:(gx + 1) * TILE] = tile

    Image.fromarray(sheet, mode="RGBA").save(out_path)
    print(f"v2: wrote {out_path.name} ({sheet.shape[1]}x{sheet.shape[0]})  "
          f"grid {cols}x{rows} @ {TILE}px")


def main() -> None:
    repack_v1_strict_grid(
        SRC / "cave_crystal_tileset.png",
        OUT / "cave_crystal_tileset_grid.png",
    )
    repack_v2_components(
        SRC / "cave_crystal_tileset_edges.png",
        OUT / "cave_crystal_tileset_edges_grid.png",
    )


if __name__ == "__main__":
    main()
