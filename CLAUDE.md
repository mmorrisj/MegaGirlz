# CLAUDE.md

Context and working rules for AI coding assistants on this repo. See README.md for the full concept and roadmap.

## Project summary

Top-down, local co-op 2D adventure in **Godot 4 / GDScript**. 1–3 players on one shared screen control three sisters (Gigi, Evie, Lucy), each with a unique ability. Puzzles require combining abilities. Players can swap to any sister not controlled by another player. Art comes from purchased pixel-art sprite packs.

## How to work in this repo

- **Small, incremental changes.** One feature or fix per change. Propose the next step rather than implementing several milestones at once.
- **Follow the roadmap order** in README.md unless asked otherwise.
- **Give honest feedback.** If a requested approach conflicts with Godot best practices or will cause pain later (especially with multiplayer input or swapping), say so and suggest the alternative.
- Explain Godot-specific concepts briefly when introducing them. The maintainer is an experienced Python developer who is new to Godot.

## Godot conventions

- Godot 4.x APIs only (e.g. `CharacterBody2D`, `TileMapLayer`, `AnimatedSprite2D`). No Godot 3 patterns (`KinematicBody2D`, `move_and_slide` with arguments, `TileMap` for new work).
- **Static typing in GDScript everywhere**: `var speed: float = 120.0`, typed function signatures.
- Style: follow the official GDScript style guide. snake_case for files, functions, and variables; PascalCase for `class_name` and nodes.
- **Composition over inheritance.** Prefer reusable child-node components (e.g. `HealthComponent`, `AbilityComponent`) over deep class hierarchies.
- Use **signals** for decoupled communication. Avoid `get_node` paths reaching up or across the tree.
- Use autoloads sparingly, only for true global systems (e.g. `PlayerManager` for device-to-player assignment and swapping).
- Use `@export` for tunable values so they can be adjusted in the editor.
- Keep scenes and scripts paired by name: `scenes/characters/gigi.tscn` ↔ `scripts/characters/gigi.gd`.

## Multiplayer input (critical design constraint)

- Up to 3 local players, each bound to a specific input device (keyboard or controller ID).
- **Do not rely on default global input actions** (`ui_left`, etc.) for gameplay. They merge all devices. Use a per-player input layer that filters `InputEvent.device`, or generate per-player actions (e.g. `p1_move_left`).
- Character control must be **decoupled from player identity**: a sister is controlled by whichever player slot is assigned to her. Swapping changes the assignment, never the character scene.
- Support drop-in/drop-out (a controller connecting or disconnecting mid-game).

## Camera

- Single shared `Camera2D` that frames all active players, with min/max zoom limits. No split-screen.

## Assets

- Never commit purchased assets to a public repo. The repo should stay private while it contains them.
- When adding a pack, also add `licenses/<pack-name>/` and an entry in `CREDITS.md`.
- Pixel art: nearest-neighbor filtering, integer scaling.

## Out of scope (unless explicitly requested)

- Online/networked multiplayer
- Split-screen
- 3D
