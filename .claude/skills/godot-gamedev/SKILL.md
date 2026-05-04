---
name: godot-gamedev
description: >
  Build and extend 2D games in Godot 4 with GDScript. Covers FSM patterns, signals, scene
  instancing, physics, nodes, exports, and educational battle system architecture.
  Trigger: "add state", "new enemy", "gdscript", "godot scene", "signal", "FSM", "battle",
  "question", "level", "player", "add node", "create scene".
---

# Godot 4 Game Development

Build and extend this Godot 4.1.2 educational platformer using GDScript, scene instancing, and the existing FSM architecture.

---

## STOP: Read Before Touching Any State Logic

**All character and enemy behaviour runs through the FSM.**

- `scripts/fsm.gd` — manages state transitions
- `scripts/state.gd` — base class for all states

Never add behaviour logic directly into `_process()` or `_physics_process()` on a character node. Always create or extend a state.

---

## Reference Files

| When working on... | Read first |
|--------------------|------------|
| Adding a new player state | [fsm-patterns.md](references/fsm-patterns.md) |
| Adding a new enemy type | [fsm-patterns.md](references/fsm-patterns.md) |
| Cross-system communication | [signals-and-events.md](references/signals-and-events.md) |
| Battle / MCQ system | [battle-architecture.md](references/battle-architecture.md) |

---

## Architecture Decisions (Decide Early)

### Where does this logic live?

| Logic type | Where it goes |
|------------|---------------|
| Character behaviour | FSM state in `scripts/forresta/` or `scripts/enemies/` |
| Persistent data (score, topic, character) | `scripts/globals.gd` autoload |
| Cross-node events | `scripts/events.gd` EventBus — emit a signal, don't get_node |
| Scene transitions | `scripts/scene_changer.gd` autoload |
| Battle flow | `scripts/battle_manager.gd` |
| MCQ data | `scripts/question_bank.gd` |

---

## Core Patterns

### Node references — use @onready, not get_node strings

```gdscript
# CORRECT
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

# WRONG — breaks on rename, no type hints
var sprite = get_node("AnimatedSprite2D")
```

### Exporting variables for editor tweaking

```gdscript
@export var speed: float = 200.0
@export var jump_force: float = -400.0
@export var topic_id: int = 1
```

### Signals — define then emit

```gdscript
signal health_changed(new_health: int)
signal enemy_died

# Emit
health_changed.emit(current_health)

# Connect in code
enemy.enemy_died.connect(_on_enemy_died)
```

### EventBus pattern (events.gd)

```gdscript
# Emit from anywhere
Events.battle_started.emit(enemy_data)

# Listen from anywhere
Events.battle_started.connect(_on_battle_started)
```

### Scene instancing

```gdscript
const EnemyScene = preload("res://scenes/basic_enemy_template.tscn")

var enemy = EnemyScene.instantiate()
enemy.global_position = spawn_point.global_position
add_child(enemy)
```

### Delta time — always use it for movement

```gdscript
# CORRECT — frame-rate independent
velocity.x = direction * speed
move_and_slide()

# WRONG for timers — use delta
position.x += speed * delta
```

---

## Adding a New Player State

1. Create `scripts/forresta/my_state.gd` extending `State`
2. Implement `enter()`, `exit()`, `update(delta)`, `physics_update(delta)`
3. Add the state node to `scenes/forresta_2.tscn` under the FSM node
4. Set the state's name to match the transition key used in sibling states

```gdscript
extends State
class_name MyState

func enter() -> void:
    owner.animated_sprite.play("my_animation")

func update(delta: float) -> void:
    if Input.is_action_just_pressed("jump"):
        fsm.transition_to("Jump")

func physics_update(delta: float) -> void:
    owner.velocity.x = owner.direction * owner.speed
    owner.move_and_slide()

func exit() -> void:
    pass
```

---

## Adding a New Enemy Type

1. Duplicate `scenes/basic_enemy_template.tscn` → rename it
2. Create `scripts/enemies/my_enemy.gd` extending `BasicEnemy`
3. Create state scripts in `scripts/enemies/` (idle, patrol, attack, hurt, die)
4. Add state nodes to the new scene under its FSM node
5. Set `@export` variables (health, speed, damage, detection range) in the editor

---

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Logic in `_process()` directly | Bypasses FSM, causes conflicts | Put it in a State |
| `get_node("../../Player")` | Breaks on scene restructure | Use EventBus or pass reference via `@export` |
| Storing progress in a local variable | Lost on scene change | Use `Globals` autoload |
| Hardcoded question strings | Hard to maintain per topic | Add to `question_bank.gd` |
| Direct scene change with `get_tree().change_scene_to_file()` | Skips transition effects | Use `SceneChanger` autoload |
| One script doing everything | Hard to extend | Split into FSM states |

---

## Remember

The FSM, EventBus, and Globals are the three pillars of this project. Every new system should plug into one of them rather than introducing a new communication pattern.

**Claude can build complete Godot features. These guidelines keep new code consistent with what already exists.**
