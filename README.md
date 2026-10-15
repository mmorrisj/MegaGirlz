# Sisters Adventure (working title)

A top-down, local co-op adventure game for 1–3 players, built in **Godot 4**. Players control three sisters, **Gigi**, **Evie**, and **Lucy**, each with a unique ability, exploring rooms and solving puzzles together on a single shared screen.

## Concept

The sisters explore a series of rooms / a small overworld to recover something lost (story TBD). Progress depends on combining their abilities.

| Sister | Ability (placeholder) | Solves |
|---|---|---|
| Gigi | Strong: pushes blocks, breaks walls | Physical obstacles |
| Evie | Ranged: wand/slingshot, hits distant switches | Out-of-reach puzzles, ranged enemies |
| Lucy | Agile/magic: dashes over gaps, reveals hidden paths | Traversal, secrets |

Abilities are placeholders. They will be tuned to fit each sister's personality.

## Core design decisions

- **Local co-op only, one shared screen.** No online multiplayer and no split-screen. Networking would multiply scope.
- **1–3 players with character swapping.** Any player can cycle to a sister not controlled by another player. Solo play swaps among all three. This must be supported from the start, not retrofitted.
- **Top-down 2D pixel art** using purchased sprite packs. Prefer a single artist's matching set (characters, enemies, tileset, UI) for a consistent style.
- **Levels built in Tiled** (or Godot's TileMapLayer) from the purchased tilesets.
- **Family-friendly difficulty.** Assume younger players, with forgiving or no fail states. Tune once playtesting starts.

## Tech stack

- Engine: Godot 4.x (stable), GDScript
- Map editor: Tiled (optional; Godot's built-in TileMapLayer is acceptable)
- Sprite editing: Aseprite
- Input: keyboard + up to 3 game controllers

## Roadmap

### Milestone 1: Vertical slice
1. One sister moving and animating (idle/walk, 4 directions) in a single room, with keyboard input.
2. Controller input and a second player, with per-device input mapping.
3. Third player plus character swapping.
4. Each sister's signature ability.
5. One room with a puzzle requiring two abilities.
6. Shared camera that keeps all active players on screen.

### Later
- Enemies, health, and a respawn/assist mechanic
- Additional rooms and overworld
- Audio, menus, save state
- Export builds (desktop first, web later)

## Assets and licensing

Purchased assets are **not** redistributable. Before committing any art or audio:

1. Confirm the license allows commercial use and modification.
2. Save the license and receipt in `licenses/<pack-name>/`.
3. Add the pack to `CREDITS.md`, including any required attribution.

**Keep this repository private** while it contains purchased assets, or store them outside git (e.g. a private asset bucket or Git LFS in a private repo). Raw purchased files must not be extractable from a public repo.

## Suggested project layout

```
assets/
  characters/{gigi,evie,lucy}/
  enemies/
  tiles/
  ui/
  audio/
scenes/
  characters/
  levels/
  ui/
scripts/
  characters/
  systems/        # input, swapping, camera, game state
licenses/
CREDITS.md
```

## Getting started

1. Install Godot 4.x (stable).
2. Clone the repo and open `project.godot` in Godot.
3. Import pixel art with nearest-neighbor filtering (Project Settings > Rendering > Textures > Default Texture Filter = Nearest).
