# Game Systems & Architecture

## Quiz Battle System

### Core Flow
```
Enemy Encounter Trigger
  ↓
Player Presses Attack
  ↓
Battle Mode Activated
  ↓
Quiz UI Appears (Question + 4 Options)
  ↓
Player Selects Answer
  ↓
Correct? → Play Attack Animation + Reduce Enemy HP
           ↓
        More Questions? → Repeat or Go to Next Phase
        
Incorrect? → Enemy Counter-Attack + Reduce Player HP
             ↓
          Player Respawn? → Go to Last Checkpoint
          
Player HP = 0 → Respawn at Checkpoint
Enemy HP = 0 → Play Death Animation → Portal Spawns
Player Reaches Portal → Level Complete Screen
```

### Health & Damage System
- **Player HP:** Tied to `healthbar` on top-left UI (not hearts)
- **Enemy HP:** Visualized with healthbar above enemy
- **Damage Values:**
  - Player damage per correct answer: 10-15 HP (enemy health 100-150)
  - Enemy damage per wrong answer: 5-10 HP (player health 50-100)
  - Adjusted per difficulty level

### Battle UI Components
1. **Top Section:** Question text box (short, dark background)
2. **Middle Section:** Game canvas (player visible, enemy visible, camera zoomed 2x)
3. **Bottom Section:** Answer buttons (4 buttons, color-coded)

**Colors for Answers:**
- A: Blue (`#2967a0`)
- B: Green (`#29919a`)
- C: Yellow (`#dd9d26`)
- D: Red (`#c54d65`)

## Level 5 - Light Puzzle System

### Light Beam Mechanics
- Light source (torch, sun, bulb)
- Light travels in straight lines
- When hitting mirror: reflects at opposite angle
- When hitting translucent panel: continues but **brightness -= 30%**
- When hitting clear panel: no brightness loss
- When hitting crystal at full brightness: activates (door opens)
- If brightness < 50% at crystal: no activation

### Mirror Behavior
- Player holds E to rotate mirror smoothly (not 4-directional)
- Rotation speed: 45°/second (adjustable)
- Mirror shows "Hold (E) to Rotate" label (stays static, doesn't rotate)
- Reflects light 90° from incidence angle

### Door Mechanics
- Moves **down** into floor when crystal activates (Z-index below tilemap)
- Returns to starting position when crystal light turns off
- Takes ~1 second to animate

### Puzzle Room Examples

**Room 1 (Intro):**
- 1 Torch + 1 Mirror (fixed angle) + 1 Crystal + 1 Door
- Goal: Light beam should hit crystal

**Room 4 (Complex):**
- 1 Torch, 6 interactive mirrors (R1-R6), multiple panels
- Optimal path: Torch → Panel → Mirror1 → Mirror2 → Panel → Mirror3 → Crystal
- Player must solve by rotating mirrors to align beams

## Enemy AI

### Standard Enemy (Slime)
```
Idle State: Patrol left/right, range 50px
Alert State: See player approaching (range 100px) → Turn to face
Attack State: In combat quiz, attack animation plays
Frozen State: During quiz UI, enemy cannot move/attack
Death State: Play explosion/death animation → Disappear
```

### Necromancer (Boss)
```
Idle: Stands in arena center
Alert: Player enters trigger area
Spawn Skeletons: Cast animation → 1 skeleton spawns per 2 seconds
Protected: Blue barrier (cannot be attacked directly)
Death: After 5 skeletons killed → Necromancer dies → Portal spawns
```

### Skeleton (Spawned)
```
Spawn: Appears left of necromancer, moves right toward player
Walk: Moves right, speeds up as gets closer
Engaged: Enters quiz battle when player attacks
Frozen: Cannot move during quiz
Dead: Disappears, next skeleton spawns
```

## Quiz Question Management

### Storage Structure
```gdscript
var questions_plants = [
  { "question": "What do plants need to grow?", 
    "answers": ["Water, light, soil", "Sugar and salt", "Air only", "Heat only"],
    "correct": 0,
    "difficulty": "easy" },
  ...
]
```

### Difficulty Tiers
- **Easy (Enemies 1-2):** Basic facts, multiple choice, obvious wrong answers
- **Medium (Enemies 3-4):** Requires understanding, some tricky options
- **Hard (Boss/BringerOfDeath):** Complex concepts, similar-looking correct answers

### Anti-Repetition
- Track answered question indices per level
- Shuffle question pool
- Don't repeat same question in same battle

## Level Completion System

### Stats Tracked
- **Completion Time:** Elapsed seconds from level start to portal entry
- **Questions Correct:** Count of correct answers
- **Questions Wrong:** Count of wrong answers
- **Enemy Defeats:** Number of enemies beaten
- **Deaths:** Number of respawns
- **Accuracy:** (Correct / Total) %

### Star Rating
- 1 Star: Completed level (40% accuracy)
- 2 Stars: Good performance (70% accuracy, < 2 deaths)
- 3 Stars: Perfect (90%+ accuracy, 0 deaths, fast time)

### Level Complete Screen
- Large "LEVEL COMPLETE" text
- Stats displayed in rows
- Star count (1-3 filled stars)
- "Continue" button → returns to Level Select
- Optional: Show high scores, world rankings

## Performance Notes

### Asset Organization
```
res://
├── graphics/
│   ├── tilesets/      (cave_crystal, forest, etc)
│   ├── characters/    (player idle/run/jump/attack)
│   ├── enemies/       (slime, skeleton, necromancer)
│   ├── ui/            (healthbars, buttons, panels)
│   └── effects/       (light beams, explosions, sparks)
├── scripts/
│   ├── battle/        (quiz_manager, battle_state)
│   ├── enemies/       (enemy.gd, slime.gd, skeleton.gd)
│   ├── puzzles/       (mirror.gd, light_beam.gd, crystal.gd)
│   └── ui/            (level_select, quiz_popup, level_complete)
├── scenes/
│   ├── levels/        (level_4_plants.tscn, level_5_light.tscn)
│   ├── menus/         (main_menu.tscn, char_select.tscn, level_select.tscn)
│   └── ui/            (level_complete_screen.tscn, hud.tscn)
```

### Optimization Tips
- Use object pooling for quiz UI (create once, reuse)
- Cache tileset collisions
- Pre-load enemy sprites on level start
- Use particle effects sparingly (light beams, explosions)

---

**Last Updated:** From Claude CLI sessions (6 months of development)
