# Sciquest Project Checklist & Status

## Level Completion Status

### Level 4: Plants 🌿 ✅ COMPLETE
- [x] Level layout designed
- [x] Platforming mechanics working
- [x] 3+ enemy types (slime variants)
- [x] Quiz questions implemented (15+ questions)
- [x] Final boss (BringerOfDeath) working
- [x] Boss defeated → portal spawns
- [x] Level complete screen with stats
- [x] Character selection integrated
- [x] Death/respawn system working

### Level 5: Properties of Light 💡 ✅ COMPLETE
- [x] Level layout designed (4 rooms)
- [x] Mirror rotation mechanic (hold E)
- [x] Light beam system (ray casting)
- [x] Translucent panel dimming
- [x] Crystal activation logic
- [x] Door movement (down into floor)
- [x] Quiz questions on light properties
- [x] Necromancer boss implemented
- [x] Skeleton spawning system
- [x] Light brightness tracking (per-hit intensity via EventBus + R4 attenuation rebalanced to 0.7 so 2-panel path passes 0.4 threshold)
- [x] Mirror label text (top_level + rotation re-zeroed every frame; removed invalid `global_rotation` set on Label that crashed every frame)
- [x] Crusher platform synchronization (await both A & C lift_started before triggering B)
- [x] Level complete screen

### Level 7: Energy ⚡ 🚧 IN PROGRESS
- [x] Sandbox scene created (this IS the live level — wired in edu_world.gd topic 7)
- [x] Energy orb asset generated
- [x] Pick-up/drop mechanic started
- [x] Power generator puzzles (5 fuel-orb types → matched generators → gates; solar torch→panel→gate; wind lever→turbine→gate)
- [x] Enemy types placed (Zone A Slime, Zone B FireWorm, Zone C Slime + FireWorm — each triggers a Topic-7 MCQ battle on attack)
- [x] Quiz questions written (20 questions in topic_7_energy.gd, registered in question_bank.gd)
- [x] Boss enemy implemented (Magmatar — reskinned BringerOfDeath + intro cinematic + barrier + teleport-gated exit)
- [x] Full level layout (4 zones: Solar/Renewable, Kinetic/Wind, Sorting Lab, Boss Arena)
- [x] Enemy patrol bounds (7 invisible layer-1 Area2D wall-stops in PatrolBounds node confine each zone's enemies; seen only by enemy WallDetector, never block the player). NOTE: walls MUST have monitoring=true — a monitoring=false Area2D is not registered for RayCast2D detection, so the WallDetector can't see it. Shape widened to 24px for margin.
- [x] Play-tested via MCP bridge (disk-screenshot + command-file input). Verified: level loads error-free; all 5 enemies spawn/sleep correctly; slime patrol confined (~835 turn at the 848 wall); forced battle shows Topic-7 MCQ ("hydroelectric dam…"), correct answer gives "Correct!" + explanation + removes an enemy heart; enemy→player melee damage works; fire_worm DieState now error-free.
- [x] BUGFIX: removed stale `_on_die_state_died` signal connection in fire_worm.tscn (method didn't exist → errored on every fire-worm death; the real handler `_on_died` is wired in code by EnemyDieState).

### Level 9: Earth 🌍 ⏳ PLANNED
- [ ] Theme design finalized
- [ ] Mechanics planned
- [ ] Quiz content written
- [ ] Assets generated
- [ ] Level layout
- [ ] Enemy types
- [ ] Boss designed
- [ ] Full implementation

### Level 10: Machines ⚙️ ⏳ PLANNED
- [ ] Theme design finalized
- [ ] Mechanics planned
- [ ] Quiz content written
- [ ] Assets generated
- [ ] Level layout
- [ ] Enemy types
- [ ] Boss designed
- [ ] Full implementation

---

## Core Game Systems

### Menu Systems
- [x] Main menu (Start, Settings, Exit)
- [x] Character selection (Ahmad, Aishah)
- [x] Level select screen
- [x] Settings (audio, difficulty)
- [x] Level complete screen
- [ ] Pause menu during gameplay
- [ ] Options menu polish

### Quiz Battle System
- [x] Quiz UI display (question + 4 answers)
- [x] Answer selection & validation
- [x] Correct answer → attack animation + enemy HP reduction
- [x] Wrong answer → enemy attacks + player HP reduction
- [x] Health bar updates
- [x] Battle state management
- [x] Multiple questions per battle
- [x] Question shuffling (no repeats)
- [ ] Difficulty scaling

### Enemy AI
- [x] Standard enemy patrol & alert
- [x] Enemy facing player when attacked
- [x] Enemy frozen during quiz UI
- [x] Enemy death animation
- [x] Necromancer boss behavior
- [x] Skeleton spawning (timed)
- [x] Skeleton movement toward player
- [ ] Advanced AI (flanking, dodging)

### Player Mechanics
- [x] Movement (WASD / Arrow keys)
- [x] Jump mechanic
- [x] Attack animation
- [x] Health system
- [x] Respawn at checkpoint
- [x] Character sprite animation sync
- [x] Animation states (idle, run, jump, attack, interact)
- [ ] Sprint/dash ability
- [ ] Item collection

### Audio
- [ ] Background music (per level)
- [ ] SFX (jump, attack, death, level complete)
- [ ] UI sounds (button click, menu hover)
- [ ] Voice narration (ElevenLabs TTS)
- [ ] Audio settings (volume, mute)

### Save/Load
- [ ] Progress saving (which levels completed)
- [ ] High scores per level
- [ ] Character selection persistence
- [ ] Settings persistence

---

## Art & Asset Generation

### Character Sprites
- [x] Ahmad (male student) - 4 animations
- [x] Aishah (female student) - 4 animations
- [x] Sprite sheet created
- [ ] Character portrait images (for selection UI)
- [ ] Idle animation polish

### Tilesets
- [x] Forest tileset (Level 4)
- [x] Cave/Crystal tileset (Level 5)
- [x] Energy factory tileset (Level 7) - in progress
- [ ] Earth/Underground tileset (Level 9)
- [ ] Machines/Factory tileset (Level 10)

### Enemy Sprites
- [x] Slime variants (green, blue, purple)
- [x] Skeleton (Level 5)
- [x] Necromancer boss
- [ ] Energy enemies (Level 7)
- [ ] Earth creatures (Level 9)
- [ ] Machine enemies (Level 10)

### UI Graphics
- [x] Health bars
- [x] Quiz UI panels
- [x] Answer buttons
- [x] Level complete screen
- [ ] Menu buttons (polish)
- [ ] Icons (heart, enemy count, etc)

### Effects & Polish
- [ ] Light beam visualization (Level 5)
- [ ] Enemy death effects (explosion, particles)
- [ ] Portal animation
- [ ] Button hover effects
- [ ] Transition animations

---

## Quiz Content

### Topics Completed
- [x] Level 4 - Plants (20 questions, 3 difficulty levels)
- [x] Level 5 - Properties of Light (18 questions, 3 difficulty levels)

### Topics In Progress
- [ ] Level 7 - Energy (questions drafted)

### Topics Planned
- [ ] Level 9 - Earth (content outline needed)
- [ ] Level 10 - Machines (content outline needed)

### Question Features
- [x] Difficulty scaling (easy → hard)
- [x] Multiple choice (4 options)
- [x] No repeats within level
- [x] Topic accuracy (aligned with curriculum)
- [ ] Hints system (optional)
- [ ] Feedback on correct/incorrect answers

---

## Code Quality & Optimization

### Performance
- [ ] Frame rate stable (60 FPS target)
- [ ] No memory leaks (test long sessions)
- [ ] Asset streaming optimized
- [ ] Enemy AI efficient (no lag with 5+ enemies)

### Code Standards
- [x] GDScript style consistent
- [ ] Comments on complex functions
- [ ] No unused variables/imports
- [ ] Functions < 100 lines

### Testing
- [ ] Unit tests for quiz system
- [ ] Integration tests (UI + gameplay)
- [ ] Edge case testing (wrong answers, rapid input, crashes)
- [ ] Mobile responsiveness testing

---

## Platform Support

### Desktop
- [x] Windows (primary dev platform)
- [ ] macOS
- [ ] Linux

### Mobile
- [ ] Android
- [ ] iOS
- [ ] Touch controls mapped
- [ ] UI responsive

---

## Documentation

- [x] Project overview (GAME_OVERVIEW_FOR_ODYSSEUS.md)
- [x] Session history export (CLAUDE_CLI_SESSION_HISTORY.md)
- [x] Systems reference (GAME_SYSTEMS_REFERENCE.md)
- [x] This checklist
- [ ] Asset generation guide (prompts, API keys)
- [ ] Deployment guide (build instructions)
- [ ] Contributing guide (for team members)

---

## Bug Tracking

### Level 5 Known Issues
- [x] Light beam dimming through multiple translucent panels
- [x] Mirror label text rotating (should stay horizontal)
- [x] Crusher platform timing not synchronized
- [x] Ladder coordinates verified (x=1464 / cell-91 center aligned with LadderTileMap; top block at floor y≈454, climb body y 472–544 spans visual rungs 447–543)
- [x] Door Z-index (all door Sprites set z_index = -1, render behind player)

### General Bugs
- [ ] UI text blurry on some resolutions (partial fix applied)
- [ ] Character sprite consistency (FAL.ai generation)
- [ ] Asset white backgrounds (manual cleanup needed)

### To Investigate
- [ ] Performance with 10+ enemies on screen
- [ ] Save/load progress edge cases
- [ ] Mobile touch input lag

---

## Next Priority Actions

### Immediate (This Week)
1. [x] Fix Level 5 light brightness tracking
2. [x] Synchronize crusher platforms
3. [x] Finish Level 5 polish
4. [ ] Generate Level 7 Energy assets

### Short Term (This Month)
1. [ ] Complete Level 7 gameplay
2. [ ] Implement audio system
3. [ ] Create Level 9 design doc
4. [ ] Balance quiz difficulty

### Medium Term (Next 2 Months)
1. [ ] Finish all 5 levels
2. [ ] Polish UI transitions
3. [ ] Performance optimization
4. [ ] Mobile testing

### Long Term (Release)
1. [ ] Full playtesting with students
2. [ ] Educational content review
3. [ ] Accessibility audit
4. [ ] Final build & deployment

---

**Last Updated:** 2025-06-01  
**Completion:** ~40%  
**Estimated Release:** 2 months (with consistent development)
