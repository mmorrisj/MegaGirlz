# MegaGirlz (working title)

A side-scrolling, local co-op action platformer for 1–3 players, built in **Godot 4**, in the spirit of Mega Man. Players control three robotic sisters, **Gigi**, **Evie**, and **Lucy**, each with a unique ability, running, jumping, and shooting through stages on a single shared screen.

## Concept

The sisters fight through a series of stages to recover something lost (story TBD). Combat and traversal reward combining their abilities.

| Sister | Ability | Signature color (placeholder) |
|---|---|---|
| Gigi | TBD | Cyan |
| Evie | TBD | Magenta |
| Lucy | TBD | Amber |

Abilities are not designed yet. They will be tuned to fit each sister's personality. Each sister has an emissive element (core, visor, or arm cannon) in her signature color so players can tell sisters apart at a glance in co-op.

## Core design decisions

- **Side-scrolling action platformer.** Run, jump, shoot, slide, and climb ladders, Mega Man style.
- **Local co-op only, one shared screen.** No online multiplayer and no split-screen. Networking would multiply scope.
- **1–3 players with character swapping.** Any player can cycle to a sister not controlled by another player. Solo play swaps among all three. This must be supported from the start, not retrofitted.
- **Fixed-screen / locked-scroll camera.** Stages are built from screen-sized rooms and scroll-locked sections, like Mega Man. This keeps all players framed without zooming (which makes pixel art shimmer). Players who fall behind are brought back with a catch-up rule (e.g. teleport or bubble respawn, TBD).
- **Modern pixel art.** Detailed sprites combined with modern effects: HDR glow, dynamic 2D lights, particles, and parallax backgrounds (think *Dead Cells*, *Katana Zero*). Prototype with free/CC0 packs; final heroes likely commissioned.
- **Game feel is a priority.** Hit-stop, screen shake, hit flash, squash and stretch, muzzle flashes, and particle effects are core features, not polish.
- **Family-friendly difficulty.** Assume younger players, with forgiving fail states. Tune once playtesting starts.

## Art direction

- **Internal resolution: 480×270**, integer-scaled (4× to 1080p).
- **Character size: about 40–48 px tall.**
- **Tile size: pick one (16×16 or 32×32) and keep every pack consistent with it.** Do not mix artists' styles in the same scene.
- **Glow:** HDR 2D (Project Settings > Rendering > Viewport > HDR 2D) plus a `WorldEnvironment` with glow. Sprites glow when their `modulate` goes above 1.0. Keep the glow threshold high.
- **Lighting:** `PointLight2D` with normal maps and a dark `CanvasModulate`. Most packs lack normal maps; generate them with a tool such as Laigter.
- **Emissive layers:** when commissioning, ask for each sister's glowing parts on a separate layer.

## Tech stack

- Engine: Godot 4.x (stable), GDScript
- Renderer: **Forward+** (HDR 2D requires Forward+ or Mobile)
- Map editor: Godot's built-in `TileMapLayer` (Tiled optional)
- Sprite editing: Aseprite
- Input: keyboard + up to 3 game controllers

## Roadmap

### Milestone 1: Vertical slice
1. One sister running, jumping, and shooting in a test room, with keyboard input and placeholder CC0 art.
2. Game feel pass on the basics: hit flash, screen shake, muzzle flash, jump squash and stretch.
3. Controller input and a second player, with per-device input mapping.
4. Third player plus character swapping.
5. Fixed-screen camera with room transitions and a catch-up rule for players left behind.
6. Visual pass: HDR glow, one dynamic light, parallax background.
7. One enemy type and each sister's signature ability.

### Later
- Health, damage, and a respawn/assist mechanic
- Bosses, more stages, stage select
- Commissioned sister sprites
- Audio, menus, save state
- Export builds (desktop first; web is lower priority because the web build uses the Compatibility renderer, which does not support HDR 2D glow)

## Assets and licensing

Prototype with free/CC0 packs (e.g. ansimuz's *Mega Bot* and *Warped* series on itch.io). "Free" is not always CC0: check every license.

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
  backgrounds/    # parallax layers
  vfx/            # particles, shaders
  ui/
  audio/
scenes/
  characters/
  levels/
  vfx/
  ui/
scripts/
  characters/
  components/     # reusable child-node components
  systems/        # input, swapping, camera, game state
licenses/
CREDITS.md
```

## Getting started

1. Install Godot 4.7 or newer (stable, standard build, not .NET).
2. Clone the repo and open `project.godot` in Godot.
3. Press F5 to run. `scenes/main.tscn` is the entry scene.

`project.godot` already sets the pixel-art defaults: 480×270 viewport, `viewport` stretch mode with integer scaling, nearest-neighbor texture filtering, 2D pixel snapping, and HDR 2D on the Forward+ renderer. Change them only in Project Settings, not by hand-editing the file.
