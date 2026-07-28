# Contributing to Sciquest

Welcome to the team! This guide explains how we work together on this Godot project.

## Setup (one-time)

1. Install [Git](https://git-scm.com/downloads) and [Godot 4.1.2](https://godotengine.org/download/archive/).
2. Clone the repo:
   ```bash
   git clone https://github.com/K4zari/Sciquest.git
   cd Sciquest
   ```
3. Open the project in Godot (Import → select `project.godot`).
4. Tell Git who you are:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your-github-email@example.com"
   ```

## Daily Workflow

### 1. Always pull before you start

```bash
git checkout main
git pull
```

This grabs everyone's latest changes so you're not working on outdated code.

### 2. Create a branch for your task

Never work directly on `main`. Make a branch named after your feature:

```bash
git checkout -b feature/slime-enemy
```

Branch naming convention:
- `feature/...` — new features (e.g. `feature/cave-level`)
- `fix/...` — bug fixes (e.g. `fix/battle-ui-overlap`)
- `content/...` — questions, sprites, levels (e.g. `content/topic-7-questions`)

### 3. Work on your task

Edit files, test in Godot. Commit often with clear messages:

```bash
git add .
git commit -m "add slime idle and attack states"
```

**Good commit messages:**
- `add archer enemy attack animation`
- `fix battle UI button alignment`
- `add 5 questions for Topic 4 Plants`

**Bad commit messages:**
- `update`
- `stuff`
- `asdf`

### 4. Push your branch and open a Pull Request

```bash
git push -u origin feature/slime-enemy
```

Then go to GitHub → click **Compare & pull request** → write a short description → request review from a teammate.

### 5. After your PR is merged

```bash
git checkout main
git pull
git branch -d feature/slime-enemy
```

## Avoiding Merge Conflicts in Godot

Godot scene files (`.tscn`) and resource files (`.tres`) are tricky to merge. Follow these rules:

- **Communicate before editing shared scenes** like `edu_world.tscn`, `level_template.tscn`, `hud.tscn`. Post in the team chat: "I'm editing edu_world.tscn now."
- **Split work by file** — one person on `sciquest.gd`, another on `battle_manager.gd`.
- **Don't both edit the same scene at the same time.**
- **Pull frequently** — at least once a day, more if multiple people are active.
- **Push when done** — don't sit on changes for days.

## Project Structure (where to put things)

| What you're adding | Where it goes |
|--------------------|---------------|
| New enemy | `scenes/` + `scripts/enemies/` |
| New player ability/state | `scripts/sciquest/` |
| New level | `scenes/` (extends `level_template.tscn`) |
| New questions | `scripts/question_bank.gd` |
| UI screen | `scenes/` + `scripts/` |
| Sprites | `graphics/` |
| Sounds/music | `sounds/` (create if missing) |

## Architecture Rules

These are non-negotiable to keep the codebase clean:

1. **Use the FSM** — extend `fsm.gd` / `state.gd`, never put state logic in `_process()`.
2. **Use EventBus** (`events.gd`) for cross-system signals, not `get_node()` chains.
3. **Use Globals** (`globals.gd`) for data that persists across scenes (score, character choice).
4. **New enemies must extend** `basic_enemy_template.tscn` and follow the existing state pattern.
5. **All scene transitions** go through `scene_changer.gd`.

## Team Roles (suggested split)

To minimize file collisions:

- **Player & combat** — `scripts/sciquest/`, attack systems
- **Enemies** — `scripts/enemies/`, enemy scenes
- **Levels & world** — level scenes, `world.gd`, `edu_world.gd`
- **UI & HUD** — `hud.gd`, `main_menu.gd`, `battle_ui.gd`
- **Education content** — `question_bank.gd`, `battle_manager.gd`

## Useful Git Commands

| Command | What it does |
|---------|--------------|
| `git status` | See what you've changed |
| `git pull` | Download teammates' latest changes |
| `git branch` | List your branches |
| `git checkout <branch>` | Switch branches |
| `git log --oneline` | See commit history |
| `git diff` | See unstaged changes line-by-line |

## When You Get Stuck

1. **Merge conflict?** Don't panic. Open the conflicted file — Git marks the conflicts with `<<<<<<<`. Pick which version to keep, save, then `git add` + `git commit`.
2. **Accidentally pushed broken code?** Fix it in a new commit, don't try to delete history.
3. **Lost work after a `git` command?** Stop. Ask in the team chat before running anything else — most things can be recovered.

## Reporting Bugs / Suggesting Features

Use **GitHub Issues** (the Issues tab on the repo page). Use the labels:
- `bug` — something is broken
- `enhancement` — new feature idea
- `content` — questions, sprites, levels needed
- `question` — clarification needed

---

Happy building! 🎮
