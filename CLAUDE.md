# CLAUDE.md

This file provides guidance to Claude Code when working in this Godot 4.1.2 project.

## Project Overview

A 2D educational platformer for Year 4 Malaysian Science (KSSR). Players explore themed worlds and
fight enemies through turn-based MCQ battles covering 5 science topics.

**Characters:** Ahmad (male) and Aishah (female) — sprites in `graphics/`

## Science Topics & World Themes

| Topic | Theme |
|-------|-------|
| Topic 4 — Plants | Forest |
| Topic 5 — Properties of Light | Cave / Crystal |
| Topic 7 — Energy | Volcano / Industrial |
| Topic 9 — Earth | Space / Planet |
| Topic 10 — Machines | Steampunk Factory |

## Key Files & Architecture

### Player
- Scene: `scenes/forresta_2.tscn`
- Script: `scripts/forresta/forresta.gd`
- States: `scripts/forresta/` — idle, run, jump, fall, dash, attack, block, cast, hurt, die, crouch, slide, wall_slide, edge_grab, ladder_climb, teleport, sit, drown

### Levels & World
- Level base: `scripts/level.gd`
- Level template scene: `scenes/level_template.tscn`
- World loader: `scripts/world.gd` — instantiates player into levels as `player_scene`
- Educational world: `scripts/edu_world.gd` / `scenes/edu_world.tscn`

### Enemies
- Base template scene: `scenes/basic_enemy_template.tscn`
- Enemy types: archer, bat, bringer_of_death, fire_worm, necromancer, nightborne, skeleton, skull_wolf, slime
- Each enemy has its own states in `scripts/enemies/`

### Educational Systems
- Battle manager: `scripts/battle_manager.gd` — controls MCQ battle flow
- Battle UI: `scripts/battle_ui.gd` — question display and answer buttons
- Question bank: `scripts/question_bank.gd` — MCQ data per topic

### Core Systems
- FSM: `scripts/fsm.gd` + `scripts/state.gd` — **always extend this, never bypass it**
- Globals autoload: `scripts/globals.gd` — persistent data (score, topic, character choice)
- EventBus autoload: `scripts/events.gd` — cross-system signals
- SceneChanger autoload: `scripts/scene_changer.gd` — all scene transitions

### UI & HUD
- HUD: `scripts/hud.gd` / `scenes/hud.tscn`
- Main menu: `scripts/main_menu.gd` / `scenes/main_menu.tscn`
- Character select: `scripts/character_select.gd` / `scenes/character_select.tscn`
- Level select: `scripts/level_select.gd` / `scenes/level_select.tscn`

### Utilities
- Checkpoint: `scripts/checkpoint.gd`
- Health bar: `scripts/health_bar.gd`
- Knockback state: `scripts/knockback_state.gd`
- Hurtbox: `scripts/hurtbox.gd`
- Moving platform: `scripts/moving_platform.gd`

## Game Design Rules

- All levels unlocked from start — no progression gates (classroom-friendly)
- Language: English
- MCQ: 15–20 questions per topic from KSSR Year 4 Science
- Lose state: show correct answer + explanation → respawn at last checkpoint
- Battle: turn-based MCQ — player answers question to attack enemy

## Skills Available

| Task | Skill |
|------|-------|
| GDScript, nodes, FSM, signals, scene instancing | `godot-gamedev` |
| Generating pixel art sprites and walk cycles | `retro-diffusion` |
| Generating reference images / character art | `fal-ai-image` |

## Development Rules

- Always check if a system exists before building a new one
- Extend the FSM (`fsm.gd` / `state.gd`) — do not add state logic directly into `_process()`
- Use EventBus (`events.gd`) for cross-system communication, not direct `get_node()` chains
- Use Globals (`globals.gd`) for data that persists across scenes
- New enemy types must extend `basic_enemy_template.tscn` and follow the existing state pattern
