#!/usr/bin/env python3
"""Generate scenes/level_10_machines.tscn — the Steam Factory (Topic 10).

Geometry is gated by walls too tall to jump: each machine (see-saw, pulley, ramp)
is the only way up and over to the next chamber. The finale uses a lever-driven gear
(WindTurbine) to open a CrusherDoor shutter to the boss arena.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "scenes" / "level_10_machines.tscn"

T = 32              # tile size (Globals.TILE_SIZE)
W = 120             # level width in tiles
FLOOR_TOP = 15      # cy of floor surface row

# ── atlas tiles (col,row) in the 8x8 machines tileset, all collidable ──
A_SURF = (1, 5)
A_FILL = (2, 6)
A_CEIL = (5, 1)
A_WALL = (4, 2)

solids = {}  # (cx,cy) -> (ax,ay)


def fill(x0, x1, y0, y1, atlas):
    for x in range(x0, x1 + 1):
        for y in range(y0, y1 + 1):
            solids[(x, y)] = atlas


# floor (surface + fill), ceiling, side walls
fill(0, W - 1, FLOOR_TOP, 20, A_FILL)
fill(0, W - 1, FLOOR_TOP, FLOOR_TOP, A_SURF)
fill(0, W - 1, 1, 2, A_CEIL)
fill(0, 0, 3, 14, A_WALL)
fill(W - 1, W - 1, 3, 14, A_WALL)

# chamber-dividing walls (top surface flush so the player can stand on them)
fill(28, 29, 8, 14, A_WALL)   # Wall A  (see-saw clears 7 tiles -> top cy8)
fill(28, 29, 8, 8, A_SURF)
fill(56, 57, 8, 14, A_WALL)   # Wall B  (pulley clears 7 tiles -> top cy8)
fill(56, 57, 8, 8, A_SURF)
fill(84, 85, 11, 14, A_WALL)  # Wall C  (ramp climbs 4 tiles -> top cy11)
fill(84, 85, 11, 11, A_SURF)


def s32(v):
    v &= 0xFFFFFFFF
    return v - 0x100000000 if v >= 0x80000000 else v


def cell_ints(x, y, ax, ay, src=0, alt=0):
    i0 = (x & 0xFFFF) | ((y & 0xFFFF) << 16)
    i1 = (src & 0xFFFF) | ((ax & 0xFFFF) << 16)
    i2 = (ay & 0xFFFF) | ((alt & 0xFFFF) << 16)
    return [s32(i0), s32(i1), s32(i2)]


data = []
for (x, y), (ax, ay) in sorted(solids.items(), key=lambda kv: (kv[0][1], kv[0][0])):
    data += cell_ints(x, y, ax, ay)
tile_data = ", ".join(str(v) for v in data)

# ── external resources ──
ext = [
    ("PackedScene", "uid://cb4nnnlumx3eq", "res://scenes/level_template.tscn", "1_tmpl"),
    ("TileSet", None, "res://resources/machines_tile_set.tres", "2_tset"),
    ("Texture2D", None, "res://graphics/topic_10_machines/factory_bg.png", "3_bg"),
    ("Texture2D", None, "res://graphics/topic_10_machines/factory_bg_far.png", "4_bgf"),
    ("PackedScene", "uid://dx73yjcnavc52", "res://scenes/lever.tscn", "5_lever"),
    ("PackedScene", None, "res://scenes/machines/see_saw.tscn", "6_seesaw"),
    ("PackedScene", "uid://dmkcj3eu6uu5e", "res://scenes/platform.tscn", "7_plat"),
    ("PackedScene", "uid://caw4t6y2winda", "res://scenes/wind_turbine.tscn", "8_turb"),
    ("PackedScene", None, "res://scenes/machines/ramp.tscn", "9_ramp"),
    ("PackedScene", "uid://dcrush7door0a", "res://scenes/crusher_door.tscn", "10_door"),
    ("PackedScene", "uid://dmwe3em7ukh0w", "res://scenes/info_board.tscn", "11_info"),
    ("PackedScene", "uid://dgeyiu02mqyyj", "res://scenes/checkpoint.tscn", "12_chk"),
    ("PackedScene", "uid://ddjjdr5oerhtx", "res://scenes/slime.tscn", "13_slime"),
    ("PackedScene", "uid://dqqcmc062f1l5", "res://scenes/bringer_of_death.tscn", "14_boss"),
    ("PackedScene", "uid://kwvv7ktseocr", "res://scenes/teleport.tscn", "15_tport"),
]

L = []
L.append('[gd_scene load_steps=%d format=3]' % (len(ext) + 1))
L.append('')
for typ, uid, path, rid in ext:
    if uid:
        L.append('[ext_resource type="%s" uid="%s" path="%s" id="%s"]' % (typ, uid, path, rid))
    else:
        L.append('[ext_resource type="%s" path="%s" id="%s"]' % (typ, path, rid))
L.append('')

# root (instance of the level template)
L.append('[node name="Level10Machines" instance=ExtResource("1_tmpl")]')
L.append('topic_id = 10')
# The player camera defaults to limit_bottom = 448, which is ABOVE the floor (y480),
# so the player would be off the bottom of the screen. Let the camera follow down.
L.append('camera_limit_bottom_override = 660')
L.append('')

# warm, dim factory ambience
L.append('[node name="CanvasModulate" type="CanvasModulate" parent="."]')
L.append('color = Color(0.82, 0.74, 0.66, 1)')
L.append('')

# parallax background
L.append('[node name="ParallaxBackground" type="ParallaxBackground" parent="."]')
L.append('')
L.append('[node name="Far" type="ParallaxLayer" parent="ParallaxBackground"]')
L.append('motion_scale = Vector2(0.15, 0.15)')
L.append('motion_mirroring = Vector2(1344, 0)')
L.append('[node name="Sprite2D" type="Sprite2D" parent="ParallaxBackground/Far"]')
L.append('texture_filter = 1')
L.append('position = Vector2(0, -80)')
L.append('scale = Vector2(1.4, 1.4)')
L.append('texture = ExtResource("4_bgf")')
L.append('centered = false')
L.append('z_index = -20')
L.append('')
L.append('[node name="Near" type="ParallaxLayer" parent="ParallaxBackground"]')
L.append('motion_scale = Vector2(0.35, 0.3)')
L.append('motion_mirroring = Vector2(1344, 0)')
L.append('[node name="Sprite2D" type="Sprite2D" parent="ParallaxBackground/Near"]')
L.append('texture_filter = 1')
L.append('position = Vector2(0, -64)')
L.append('scale = Vector2(1.4, 1.4)')
L.append('texture = ExtResource("3_bg")')
L.append('centered = false')
L.append('z_index = -10')
L.append('modulate = Color(1, 1, 1, 0.55)')
L.append('')

# tilemap geometry
L.append('[node name="TileMap" parent="." index="0"]')
L.append('tile_set = ExtResource("2_tset")')
L.append('format = 2')
L.append('layer_0/tile_data = PackedInt32Array(%s)' % tile_data)
L.append('')

# player spawn
L.append('[node name="PlayerSpawnSpot" parent="." index="9"]')
L.append('position = Vector2(112, 440)')
L.append('')


def info(name, x, y, text):
    L.append('[node name="%s" parent="InfoBoards" instance=ExtResource("11_info")]' % name)
    L.append('position = Vector2(%d, %d)' % (x, y))
    L.append('description = "%s"' % text)
    L.append('')


def checkpoint(name, x, y):
    L.append('[node name="%s" parent="." instance=ExtResource("12_chk")]' % name)
    L.append('position = Vector2(%d, %d)' % (x, y))
    L.append('')


def enemy(name, res, x, y, boss=False, guard=None):
    if guard:
        L.append('[node name="%s" parent="Enemies" node_paths=PackedStringArray("teleport_guarded") instance=ExtResource("%s")]' % (name, res))
    else:
        L.append('[node name="%s" parent="Enemies" instance=ExtResource("%s")]' % (name, res))
    L.append('position = Vector2(%d, %d)' % (x, y))
    if boss:
        L.append('is_boss = true')
    if guard:
        L.append('teleport_guarded = NodePath("%s")' % guard)
    L.append('')


# ── Chamber 1: Levers & Fulcrum ──
info("Info1", 200, 412,
     "LEVERS & FULCRUM\\nPick the fulcrum (press E), then step on the arm.\\nA fulcrum CLOSE to the load lifts you the highest!")
L.append('[node name="Slime1" parent="Enemies" instance=ExtResource("13_slime")]')
L.append('position = Vector2(384, 452)')
L.append('')
L.append('[node name="SeeSaw" parent="Interactables" instance=ExtResource("6_seesaw")]')
L.append('position = Vector2(816, 480)')
L.append('')

# ── Chamber 2: Pulley ──
checkpoint("Checkpoint2", 992, 452)
info("Info2", 1080, 412,
     "PULLEY\\nPull the lever — the wheel turns and the platform rises.\\nPulling DOWN lifts the load UP.")
L.append('[node name="Platform2" parent="Platforms" instance=ExtResource("7_plat")]')
L.append('position = Vector2(1696, 480)')
L.append('switchable = true')
L.append('width = 4')
L.append('move_range_vert = 14')
L.append('speed = 8')
L.append('interval = 1.6')
L.append('tile_type = 1')
L.append('')
L.append('[node name="Turbine2" parent="Interactables" instance=ExtResource("8_turb")]')
L.append('position = Vector2(1712, 240)')
L.append('')
L.append('[node name="Lever2" parent="Interactables" node_paths=PackedStringArray("targets") instance=ExtResource("5_lever")]')
L.append('position = Vector2(1536, 452)')
L.append('two_way = true')
L.append('targets = [NodePath("../../Platforms/Platform2"), NodePath("../Turbine2")]')
L.append('')

# ── Chamber 3: Inclined plane ──
checkpoint("Checkpoint3", 1888, 452)
info("Info3", 1984, 412,
     "INCLINED PLANE\\nThe wall is too high to jump. Pull the lever to drop\\nthe ramp, then walk up the gentle slope.")
L.append('[node name="Ramp3" parent="Platforms" instance=ExtResource("9_ramp")]')
L.append('position = Vector2(2496, 480)')
L.append('')
L.append('[node name="Lever3" parent="Interactables" node_paths=PackedStringArray("targets") instance=ExtResource("5_lever")]')
L.append('position = Vector2(2400, 452)')
L.append('targets = [NodePath("../../Platforms/Ramp3")]')
L.append('')

# ── Finale: complex machine + boss ──
checkpoint("Checkpoint4", 2784, 452)
info("Info4", 2880, 412,
     "COMPLEX MACHINE\\nA lever turns the gears that drive the great engine.\\nCombine simple machines to open the factory gate!")
L.append('[node name="TurbineFinal" parent="Interactables" instance=ExtResource("8_turb")]')
L.append('position = Vector2(3104, 420)')
L.append('crystal_id = "m_final"')
L.append('')
L.append('[node name="LeverFinal" parent="Interactables" node_paths=PackedStringArray("targets") instance=ExtResource("5_lever")]')
L.append('position = Vector2(3008, 452)')
L.append('targets = [NodePath("../TurbineFinal")]')
L.append('')
L.append('[node name="DoorFinal" parent="Interactables" instance=ExtResource("10_door")]')
L.append('position = Vector2(3200, 480)')
L.append('linked_crystal_id = "m_final"')
L.append('height = 12')
L.append('environment = 4')
L.append('')

# boss + level-end teleport
enemy("Boss", "14_boss", 3520, 440, boss=True, guard="../../Teleport")
L.append('[node name="Teleport" parent="." node_paths=PackedStringArray("level_node") instance=ExtResource("15_tport")]')
L.append('position = Vector2(3712, 432)')
L.append('active = false')
L.append('is_level_end = true')
L.append('level_node = NodePath("..")')
L.append('')

OUT.write_text("\n".join(L) + "\n", newline="\n")
print("wrote", OUT, "with", len(solids), "tiles,", len(L), "lines")
