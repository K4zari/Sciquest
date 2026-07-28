# Sciquest - Educational Platformer

## Project Overview

**Goal:** A 2D platformer game for Year 4 students combining platforming with science education through interactive quiz battles.

**Target Audience:** Age 9-10 (Year 4)  
**Platform:** Godot 4.1.2  
**Repository:** https://github.com/K4zari/Sciquest  
**Status:** 40% Complete (2 of 5 levels finished)

---

## Game Structure

### Main Menu
- Start Adventure button → Level Select
- Settings (audio, difficulty)
- Exit

### Character Selection
- Ahmad (male student)
- Aishah (female student)
- Selected character persists through gameplay

### Level Select Screen
Shows 5 levels, player chooses which to play:
1. **Level 4 - Plants** ✓ COMPLETE
2. **Level 5 - Properties of Light** ✓ COMPLETE
3. **Level 7 - Energy** 🚧 IN PROGRESS
4. **Level 9 - Earth** ⏳ PLANNED
5. **Level 10 - Machines** ⏳ PLANNED

### Gameplay Loop (Each Level)
1. **Exploration Phase** → Navigate platformer level
2. **Enemy Encounter** → Approach enemy, press Attack
3. **Quiz Battle** → Answer science questions
4. **Progression** → Defeat enemies to reach boss
5. **Boss Fight** → Final quiz battle
6. **Level Complete Screen** → Show stats (time, score, deaths)
7. **Portal Exit** → Return to level select

---

## Quiz Battle System

### How It Works
- Player attacks enemy → Quiz UI appears (question + 4 answer options)
- Correct answer → Play attack animation, reduce enemy HP
- Wrong answer → Enemy attacks, reduce player HP
- All questions answered OR enemy HP = 0 → Battle ends
- Enemy dies → Portal appears to exit level

### Questions Database
- 15-20 questions per topic
- Early questions easier (difficulty ramps)
- Final boss gets hardest questions
- No repeats within same level

### Battle UI Layout
- **Top:** Question text (narrow box)
- **Middle:** Game canvas (player & enemy visible, camera zoomed in)
- **Bottom:** 4 answer buttons (color-coded: blue, green, yellow, red)

---

## Level Designs

### Level 4: Plants 🌿
**Theme:** Forest environment  
**Mechanics:**
- Standard platforming with platforms, gaps, hazards
- Plant enemies scattered throughout (Slime variants)
- Quiz questions on plant biology (roots, photosynthesis, growth)
- Final boss: "BringerOfDeath" (plant enemy)

**Assets:** Forest tileset, plant enemies, green color palette

### Level 5: Properties of Light 💡
**Theme:** Crystal cave  
**Mechanics:**
- **Mirror Puzzles:** Player rotates mirrors to redirect light beams
- **Translucent Panels:** Reduce light brightness as it passes through
- **Crystal Activation:** Light beam on crystal opens doors
- **Layered Puzzle:** Multiple mirrors & panels to solve
- **Necromancer Boss:** Spawns 5 skeleton enemies, quiz battles each

**Assets:** Cave tileset, crystals, mirrors, light beams, skeleton enemies

**Puzzle Progression:**
- Room 1: Intro (1 mirror, 1 crystal)
- Room 2: 2 mirrors + 1 translucent panel
- Room 3: 3 mirrors + 2 panels (harder alignment)
- Room 4: Crusher platforms (moving obstacles) + complex mirror chain
- Final: Necromancer arena with light puzzle guard

### Level 7: Energy ⚡ (In Development)
**Theme:** Power generation facility  
**Mechanics:**
- **Energy Orbs:** Player picks up/drops energy balls
- **Power Generators:** Place orbs to power devices
- **Timed Challenges:** Orbs need to reach destination quickly
- **Quiz battles** with energy-themed enemies

**Status:** Sandbox prototype, mechanics being tested

### Level 9: Earth 🌍 (Planned)
**Theme:** Planetary/underground environment  
**Mechanics:** TBD (tectonic plates? rock layers?)

### Level 10: Machines ⚙️ (Planned)
**Theme:** Mechanical factory  
**Mechanics:** TBD (gears? levers?)

---

## Technical Stack

| Component | Details |
|-----------|---------|
| **Engine** | Godot 4.1.2 |
| **Language** | GDScript |
| **Audio** | ElevenLabs (TTS for narration), custom SFX |
| **Art Gen** | Retro Diffusion (tilesets), FAL.ai (characters) |
| **Database** | SQLite (quiz questions, progress) |
| **VCS** | Git + GitHub |
| **Development** | Claude CLI + Godot MCP (vibecode) |

---

## Key Scripts & Systems

### Core Systems
- `globals.gd` — Global state (current level, selected character)
- `quiz_manager.gd` — Quiz question storage & logic
- `audio_manager.gd` — Music & SFX playback
- `level_select.tscn` — Level picker UI
- `char_select.tscn` — Character selection

### Battle System
- `quiz_popup.gd` — Quiz UI display & input handling
- `battle_state.gd` — Turn-based battle controller
- `enemy.gd` (base) → `slime.gd`, `skeleton.gd`, `necromancer.gd`
- `player.gd` — Player health, input, animation sync

### Puzzles (Level 5)
- `mirror.gd` — Rotatable mirror, light beam direction
- `light_beam.gd` — Ray casting, brightness dimming through panels
- `crystal.gd` — Activates when lit, opens door
- `translucent_panel.gd` — Reduces light intensity

---

## Art Assets

### Tilesets
- **Forest** (Level 4): Grass, dirt, stone platforms, trees
- **Cave/Crystal** (Level 5): Stone, crystal, ice, light effects
- **Energy Factory** (Level 7): Metal, electrical effects, generators
- **Earth** (Level 9): Rock layers, sand, lava (TBD)
- **Machines** (Level 10): Gears, metal, steam (TBD)

### Character Sprites
- Ahmad (male) & Aishah (female) with 4 animations each:
  - Idle (8 frames)
  - Run (6 frames)
  - Jump (6 frames)
  - Interact/Attack (10 frames)

### Enemy Sprites
- Slime variants (green, blue, purple)
- Skeleton (Level 5)
- Necromancer (boss)
- TBD for other levels

---

## Quiz Content

### Topic 1: Plants (Level 4) ✓
Sample questions:
- What do plants need to grow? (water, light, soil)
- What is photosynthesis? (converting light to energy)
- Which part of the plant absorbs water? (roots)

### Topic 2: Properties of Light (Level 5) ✓
Sample questions:
- What is refraction? (light bending through materials)
- How fast does light travel? (299,792,458 m/s)
- Can light pass through a crystal? (yes)

### Topic 3: Energy (Level 7) 🚧
- Forms of energy (kinetic, potential, thermal)
- Energy conversion (solar → electrical)
- Power generation methods

### Topic 4 & 5: TBD (Earth, Machines)

---

## Development Workflow

### Vibecode Loop (Claude CLI)
1. Start session: `claude --resume <session-id>`
2. Connect Godot: `/mcp` → verify Godot MCP ready
3. Run game: `mcp__godot__run_project`
4. Describe changes needed
5. Claude edits `.gd` files + regenerates scenes
6. Test in running game (live feedback)
7. Iterate until feature working
8. Commit: `git add . && git commit -m "feature: ..."`

### Art Generation
- **Tilesets:** Use Retro Diffusion API with prompts
- **Characters:** FAL.ai for sprite consistency
- **Cleanup:** Manual pixel art refinement if needed

### Testing Checklist
- [ ] Level plays end-to-end
- [ ] All enemies beatable
- [ ] All quiz questions appear
- [ ] No crashes or missing assets
- [ ] UI responsive (desktop + mobile)
- [ ] Save/load progress works

---

## Known Issues & TODO

### Level 5 (Light)
- [ ] Light beam dimming through multiple panels (brightness tracking)
- [ ] Mirror label text rotating with mirror (should stay horizontal)
- [ ] Crusher platform timing (3 blocks synchronized)
- [ ] Door disappearing behind floor tilemap

### General
- [ ] Character sprite generation consistency (FAL.ai)
- [ ] Audio implementation (ElevenLabs TTS integration)
- [ ] Mobile UI responsive testing
- [ ] Performance optimization (large levels)
- [ ] Accessibility (color-blind modes, text size)

---

## Next Steps

1. **Finish Level 5** → Debug light mechanics, finalize boss
2. **Create Level 7** → Energy orb mechanics, generators
3. **Generate Assets** → Sprites for Levels 3-5 topics
4. **Audio Polish** → Add SFX & music tracks
5. **Balance Testing** → Adjust quiz difficulty & enemy stats
6. **Polish UI** → Main menu animations, transitions
7. **Release Prep** → Performance testing, build optimization

---

## Resources

- **Repository:** https://github.com/K4zari/Sciquest
- **Godot Docs:** https://docs.godotengine.org/en/4.1/
- **GDScript Reference:** https://docs.godotengine.org/en/4.1/tutorials/scripting/gdscript/
- **GitHub Board:** (create issue tracker for bugs/features)

---

## Team Info

**Primary Developer:** Afif (via Claude CLI + vibecode)  
**Collaborators:** TBD  
**Mentors/Advisors:** Science curriculum specialists (for content review)

---

**Last Updated:** 2025-06-01  
**Version:** 0.4 (40% complete)
