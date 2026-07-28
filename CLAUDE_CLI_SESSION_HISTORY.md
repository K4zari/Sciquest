# Claude CLI Session History Export
**Game Project:** Sciquest - Educational Platformer for Year 4 Topics  
**Start Date:** Jan 2025 | **Status:** In Development (Level 5 Complete, Level 7 WIP)

---

## Session Timeline & Key Decisions

### Phase 1: Project Setup & Character Selection (Early Sessions)
- **Initial Scope:** Convert open-source 2D platformer → educational game with 5 levels (Plants, Light, Energy, Earth, Machines)
- **Major UI Components Created:**
  - Main menu (initial issues with button positioning)
  - Character select scene (Ahmad & Aishah characters)
  - Level select menu
  - Quiz manager & popup system
  
- **Issues Encountered & Fixes:**
  - Character sprite scaling (was too big/small, clipping issues)
  - Player movement input not registering (fixed with input map)
  - Quiz UI stuck on "Correct" response (state management fixed)
  - Character sprite flipping when moving left/right (animation direction fixed)

### Phase 2: Quiz Battle Mechanic (Mid Sessions)
- **Core Mechanic:** Turn-based quiz battles where correct answers reduce enemy health
- **Implementation:**
  - Player health tied to top-left UI healthbar (not hearts)
  - Enemy damage based on quiz difficulty
  - Attack animations synchronized with quiz UI
  - Enemy AI disabled during quiz to prevent double-damage
  
- **Key Tuning:**
  - Battle UI: Question box top, answer box bottom (3-section layout)
  - Camera zoom into player/enemy during combat
  - Delay before enemy death animation (1 second)
  - Enemy healthbar animation to zero on final kill

### Phase 3: Level 4 - Plants (Complete)
- **Theme:** Forest platformer with plant enemies
- **Learning Elements:**
  - Quiz questions on plant topics
  - Slime/plant enemies as quiz opponents
  - Final boss: "BringerOfDeath" with harder questions
  - Level completion screen with stats (time, questions answered, deaths, stars)

- **Polish Done:**
  - Enemy flipping to face player when attacked
  - Answer button colors (blue, green, yellow, red)
  - Portal spawn after boss defeat
  - Ladder mechanics for vertical traversal

### Phase 4: Level 5 - Properties of Light (In Progress)
- **Theme:** Cave/crystal environment with light puzzles
- **Puzzle Mechanics:**
  - Mirrors that rotate to direct light beams
  - Translucent panels that dim light intensity
  - Crystal activation by light beam (opens doors)
  - Hierarchical puzzle: Mirror→Panel→Mirror→Panel→Crystal path

- **Complexity Tuning:**
  - Multiple mirror positions (Mirror_R4, R5, R6)
  - Clear panels vs translucent panels (light behavior differs)
  - Walls around crystal with entry holes (east/west)
  - Player rotates mirrors with hold-E smooth rotation (not 4-direction)

- **Battle Integration:**
  - Necromancer as final boss
  - Spawns 5 skeletons one-by-one
  - Quiz battles for each skeleton
  - Necromancer protected by blue barrier

- **Known Issues to Fix:**
  - Light beam dimming through multiple panels (needs brightness tracking)
  - Mirror label text rotates with mirror (should be static)
  - Crusher platform timing (synchronized 3-block movement)
  - Ladder coordinates need verification

### Phase 5: Asset Generation (Retro Diffusion / FAL.ai)
- **Tools Used:**
  - Retro Diffusion for tilesets (cave/crystal theme)
  - FAL.ai for character sprite generation
  
- **Challenges:**
  - White backgrounds on generated assets (required cleanup)
  - Windmill animation looks like page flipping (needs frame refinement)
  - Character sprite consistency (Ahmad/Aishah body proportions)
  - Tileset alignment with gaps between tiles (10-14px spacing)

### Phase 6: Level 7 - Energy (Prototype)
- **Theme:** Industrial/power generation environment
- **Gameplay Concept:**
  - Energy orbs players pick up and place
  - Drop mechanic implementation
  - Power generators as interactive puzzles
  - Quiz battles with energy-themed enemies

- **Status:** Sandbox scene created, mechanics being tested

---

## Technical Architecture

### Quiz Battle System Flow
```
Player attacks → Battle mode active → Quiz UI appears
Answer question → Correct? → Play attack animation + reduce enemy HP
                              → Incorrect? → Enemy attacks + reduce player HP
All questions answered → Enemy defeated → Play death animation → Portal appears
```

### Level Structure
- Platforms & enemies scattered across layout
- Enemy encounter triggers quiz when player attacks
- Hazards & obstacles for platforming sections
- Finale trigger area where boss spawns
- Portal/exit after boss defeated

### Art Asset Locations
- Characters: `res://graphics/characters/` (idle, run, jump, interact animations)
- Tilesets: `res://graphics/tilesets/` (cave_crystal, energy_factory, etc.)
- Enemies: `res://graphics/enemies/` (slime, skeleton, necromancer)
- UI: `res://graphics/ui/` (health bars, quiz boxes, level complete screen)

### Quiz Question Database
- Stored in quiz_manager.gd as arrays per topic
- Early questions easier, final boss questions harder
- Prevents repetition by tracking answered questions
- Easy/medium/hard difficulty tiers

---

## Team Collaboration Notes
- **Game Title:** Sciquest
- **Repository:** https://github.com/K4zari/Sciquest
- **Vibecode Workflow:** Claude CLI + Godot MCP for live testing & iteration
- **Next Developer:** Refer to this document + Claude memory snapshots for context

---

## Performance & Testing Notes
- Level 4 fully playable end-to-end ✓
- Level 5 light puzzle mechanics working (minor tuning needed)
- Level 7 sandbox for feature testing
- Levels 8-9 not yet started
- All enemy AI needs balancing (movement speed, attack timing)
- UI text blurriness fixed with Option A (font rendering)

---

## API Keys & Credentials (Redacted)
- Retro Diffusion API: `[STORED IN .ENV]`
- FAL.ai API: `[STORED IN .ENV]`
- Keep these in project `.env` for art generation workflows

---

## Resuming Development
When returning to this project:
1. Check `.claude\sessions\` for most recent session ID
2. Use `claude --resume <session-id>` to restore context
3. Connect Godot MCP: `/mcp` command in Claude CLI
4. Run game: `mcp__godot__run_project` in Godot editor
5. For sprite generation: ensure API keys are in `.env`

**Last Update:** Latest session ID available in history.jsonl  
**Files Modified:** See git commit log in GitHub repo
