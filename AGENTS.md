# Paddle Up — Conventions & Verification

Godot 4.7 project (GL Compatibility). Mobile-first, viewport 1000x2100.

## Structure

- `Scripts/Core/` — shared base classes (`entity.gd`, `button_tween_helper.gd`, `game_config.gd`)
- `Scripts/Entities/` — one script per game entity (`ball.gd`, `ball_pong.gd`, `ball_bb_classic.gd`, `balls_bb.gd`, `bb_mod_player.gd`, `cpu.gd`, `player.gd`, `table.gd`, `trajectory.gd`)
- `Scripts/Levels/` — level logic (`level_bb.gd` base, `level_bb_classic.gd`, `level_bb_modern.gd`, `level_pong.gd`)
- `Scripts/UI/` — UI scripts (`in_game_ui.gd` base + per-mode UIs, `end_screen.gd`, `high_score.gd`, menus)
- `Scenes/` mirrors that split; `Globals/` holds autoloads (`Global`, `Fade`, `AudioManager`, `SaveManager`, `Background`)

## Naming rules

- Files: `snake_case.gd`. Classes: `PascalCase` via `class_name`.
- A node's **group string must equal its class_name exactly** (e.g. group `"Cpu"` — not `"CPU"`). Group lookups use `get_first_node_in_group`.
- In `.tscn` files, `groups=[...]` must be in the `[node ...]` header line, not a property line.
- Autoload names must NOT match any `class_name` (e.g. `SaveManager` has no `class_name`).
- Game tuning constants live in `Scripts/Core/game_config.gd` (`GameConfig`). Keep only single-use tuning consts local to a script.

## Saves

`SaveManager` (autoload) owns all persistence in `~/Documents/PaddleUp/`. It reads **legacy unwrapped formats** (`{"bb_clas_stats":..., "bb_clas_bricks": {...}}`, `{"HighScores": [...]}`) and writes versioned `{"version":1,"data":...}`. `bb_clas_bricks` may be a Dictionary (legacy classic) or Array (modern) — `_load_bricks` converts.

## Verification

Run from project root:

```
godot --headless --path . --import    # after adding/renaming scripts (refreshes class cache)
godot --headless --path . --quit-after 30   # full project boot gate: zero errors/warnings
```

Notes:

- Do NOT use `--check-only --script` — autoload identifiers (`Global`, `SaveManager`, ...) fail to parse outside the project context.
- External test scripts (`/tmp/...`) cannot reference autoload identifiers at parse time; use `root.get_node("SaveManager")`.
- After `git mv` of scripts, delete `.godot/` and re-import or the stale global class cache produces "Class X hides a global script class" errors.
- Nodes added during a SceneTree script's `_initialize()` never get `_ready`; add them in `_process` instead.
