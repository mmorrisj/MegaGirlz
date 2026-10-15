# CLAUDE.md

Context and working rules for AI coding assistants on this repo. See README.md for the full concept and roadmap.

## Project summary

Side-scrolling, local co-op 2D action platformer (Mega Man style) in **Godot 4 / GDScript**. 1–3 players on one shared screen control three robotic sisters (Gigi, Evie, Lucy), each with a unique ability (abilities TBD). Players can swap to any sister not controlled by another player. Art style is modern pixel art (detailed sprites plus HDR glow, 2D lights, particles), prototyped with free/CC0 packs.

## How to work in this repo

- **Small, incremental changes.** One feature or fix per change. Propose the next step rather than implementing several milestones at once.
- **Follow the roadmap order** in README.md unless asked otherwise.
- **Give honest feedback.** If a requested approach conflicts with Godot best practices or will cause pain later (especially with multiplayer input or swapping), say so and suggest the alternative.
- Explain Godot-specific concepts briefly when introducing them. The maintainer is an experienced Python developer who is new to Godot.

## Godot conventions

- Godot 4.x APIs only (e.g. `CharacterBody2D`, `TileMapLayer`, `AnimatedSprite2D`, `Parallax2D`). No Godot 3 patterns (`KinematicBody2D`, `move_and_slide` with arguments, `TileMap` for new work).
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

- Single shared `Camera2D`, Mega Man style: fixed-screen rooms and scroll-locked sections. No free zoom (non-integer zoom makes pixel art shimmer). No split-screen.
- Players who fall behind are handled by a catch-up rule (teleport or bubble respawn), not by zooming out.

## Visuals and game feel

- Internal resolution 480×270, integer-scaled. Characters about 40–48 px tall. One tile size across all packs.
- Renderer is Forward+ with HDR 2D enabled. Glow comes from `WorldEnvironment` plus `modulate` values above 1.0; keep the glow threshold high.
- Game-feel effects (hit-stop, screen shake, hit flash, particles) are core features. Build them as reusable components or signal listeners, not ad hoc code in character scripts.
- Each sister's signature color appears on an emissive element so players can identify her in co-op.

## Assets

- Never commit purchased assets to a public repo. The repo should stay private while it contains them.
- When adding a pack, also add `licenses/<pack-name>/` and an entry in `CREDITS.md`.
- Pixel art: nearest-neighbor filtering, integer scaling.
- "Free" does not mean CC0. Verify each pack's license before committing it.

## Out of scope (unless explicitly requested)

- Online/networked multiplayer
- Split-screen
- 3D
- Web export as a primary target (Compatibility renderer lacks HDR 2D glow)
