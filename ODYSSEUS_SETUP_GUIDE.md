# How to Import Your Game Project into Odysseus

This guide walks you through uploading your Sciquest game documentation and setting up Odysseus for project management.

---

## Step 1: Open Odysseus

Go to: **http://localhost:7000**

Log in with your admin credentials (set during initial setup).

---

## Step 2: Upload Documents

### Upload These Files to Odysseus Documents:

1. **GAME_OVERVIEW_FOR_ODYSSEUS.md**
   - Go to **Documents** → Click **+ New Document**
   - Title: `Sciquest - Game Overview`
   - Paste content from file
   - Save

2. **GAME_SYSTEMS_REFERENCE.md**
   - Title: `Game Systems Reference`
   - Content: Quiz battles, Level 5 puzzles, enemy AI, performance notes

3. **PROJECT_CHECKLIST.md**
   - Title: `Project Status & Checklist`
   - Content: Level progress, systems status, bugs, next actions

4. **CLAUDE_CLI_SESSION_HISTORY.md**
   - Title: `Development History & Sessions`
   - Content: Session timeline, decisions, technical notes

### Optional: Create Sub-Documents

For each level, create a document:
- `Level 4 - Plants Design`
- `Level 5 - Light Design`
- `Level 7 - Energy Design`

Each document includes:
- Theme & visuals
- Mechanics overview
- Quiz questions (sample)
- Known issues
- Status

---

## Step 3: Set Up Memory / Skills

Memory in Odysseus stores reusable knowledge. Here's what to add:

### In Odysseus Memory Section:

1. **Quiz Battle Architecture**
   - Topic: Game Systems
   - Content: Battle flow diagram, HP calculations, answer validation logic
   - Use when: Debugging battle mechanics or adding new enemy types

2. **Light Puzzle System**
   - Topic: Level 5 Mechanics
   - Content: Mirror rotation, light beam ray casting, brightness dimming
   - Use when: Adjusting puzzle difficulty or fixing light behavior

3. **Enemy AI Patterns**
   - Topic: Enemy Behavior
   - Content: State machines (Idle, Alert, Attack, Frozen, Death)
   - Use when: Adding new enemies or tweaking AI

4. **Character Animation States**
   - Topic: Player Mechanics
   - Content: Sprite frame counts, animation transitions
   - Use when: Adding new animations or fixing sync issues

5. **Asset Naming Conventions**
   - Topic: Project Organization
   - Content: File structure, naming rules, sprite sheet specs
   - Use when: Generating new assets or organizing files

### How to Add Memory in Odysseus:

1. Click **Memory** in sidebar
2. Click **+ Add Skill** or **+ Add Memory**
3. Enter topic name (e.g., "Quiz Battle System")
4. Paste relevant content
5. Save (it gets indexed in ChromaDB for smart search)

---

## Step 4: Create Task Checklist

### In Odysseus Notes & Tasks:

1. Click **Tasks**
2. Click **+ New Task** for each major item:

#### Level Completion
- [ ] Level 4 (Plants) - 100% Complete
- [ ] Level 5 (Light) - 95% Complete (needs minor fixes)
  - [ ] Fix light brightness through multiple panels
  - [ ] Synchronize crusher platforms
  - [ ] Verify ladder coordinates
- [ ] Level 7 (Energy) - 20% (in development)
- [ ] Level 9 (Earth) - 0% (planned)
- [ ] Level 10 (Machines) - 0% (planned)

#### Asset Generation
- [ ] Generate Level 7 Energy tilesets (Retro Diffusion)
- [ ] Generate character portraits (FAL.ai)
- [ ] Cleanup white backgrounds on sprites
- [ ] Create Level 9 & 10 tilesets

#### Audio
- [ ] Record background music (5 tracks)
- [ ] Generate SFX (jump, attack, enemy death)
- [ ] Integrate ElevenLabs TTS

#### Polish
- [ ] Test mobile responsiveness
- [ ] Add pause menu
- [ ] Implement save/load system
- [ ] Performance optimization

#### Documentation
- [ ] Create asset generation guide
- [ ] Write deployment instructions
- [ ] Prepare playtest rubric

### Setting Reminders:

For important deadlines, set **reminders** on tasks:
- Example: "Polish Level 5" → Set reminder for Friday 5 PM
- Get pinged on browser when due

---

## Step 5: Use Odysseus for Collaboration

### Sharing with Team Members:

If you add team members later:

1. **Settings** → **Manage Users**
2. Create new accounts for team members
3. Set privilege level (read-only vs. edit)
4. Share project link

### Organizing Team Notes:

Use **Notes** for quick ideas:
- Bug observation: "Enemy hitbox too large when frozen"
- Feature idea: "Add difficulty settings to quiz questions"
- Balance note: "Necromancer spawns skeletons too fast"

Add tags (optional):
- `#bug`, `#feature`, `#balance`, `#art`, `#audio`

---

## Step 6: Connect to Claude CLI Sessions

Odysseus Memory complements Claude CLI context:

1. **In Claude CLI:** `/claude-mem:search` finds your stored memories
2. **In Odysseus:** Documents + Memory = searchable project database
3. **Integration:** When resuming Claude CLI sessions, Claude can reference Odysseus memory if needed (via document uploads)

### Best Practices:

- **Claude CLI:** Active development, vibecode, real-time testing
- **Odysseus:** Project hub, documentation, team collaboration, long-term memory
- **Sync:** After major milestones, update Odysseus docs with latest status

---

## Step 7: Optional - Set Up Deep Research

Use Odysseus's **Deep Research** feature to:

1. Research best practices for educational games
2. Find Godot optimization tips
3. Gather science curriculum content for each topic

### Example Research:

**Topic:** "Best practices for teaching plant biology through interactive games"

1. Click **Deep Research**
2. Enter query
3. Odysseus gathers sources, synthesizes into report
4. Save report as document for reference

---

## Quick Reference: File Locations

```
C:\Users\Afif\Documents\Game based learning\
├── GAME_OVERVIEW_FOR_ODYSSEUS.md           ← Upload as Document
├── GAME_SYSTEMS_REFERENCE.md                ← Upload as Document
├── PROJECT_CHECKLIST.md                     ← Upload as Document
├── CLAUDE_CLI_SESSION_HISTORY.md            ← Upload as Document (for reference)
├── README.md                                ← Existing project README
├── .mcp.json                                ← Your Godot MCP config
├── app.py                                   ← Game source
└── (game files, scripts, assets...)
```

---

## Next: Export from Claude CLI to Odysseus

### To preserve more session history:

1. Export key conversations from Claude CLI:
   ```powershell
   Get-Content $env:USERPROFILE\.claude\history.jsonl | Select-Object -First 50
   ```

2. Manually copy important Q&A into Odysseus Documents

3. Create a "Session Index" document listing session IDs & summaries:
   ```
   | Session ID | Date | Topic | Outcome |
   |---|---|---|---|
   | 17281ae4-72ba... | 2025-03-15 | Quiz UI fix | Resolved |
   | 2fb4fab2-01ad... | 2025-04-20 | Character sprites | In progress |
   ```

---

## Summary: Your Setup

✅ **Created & ready to upload:**
- `GAME_OVERVIEW_FOR_ODYSSEUS.md` (8.5 KB)
- `GAME_SYSTEMS_REFERENCE.md` (6 KB)
- `PROJECT_CHECKLIST.md` (7.5 KB)
- `CLAUDE_CLI_SESSION_HISTORY.md` (6.3 KB)

✅ **Next: Open Odysseus and upload these 4 files to Documents**

✅ **Then: Create Memory entries for key systems**

✅ **Finally: Add Tasks for next development priorities**

---

**Expected Time:** 15-20 minutes to fully set up

**Result:** Centralized project hub + persistent memory for your game development!

---

**Questions?** Refer back to this guide or check `GAME_OVERVIEW_FOR_ODYSSEUS.md` for project context.
