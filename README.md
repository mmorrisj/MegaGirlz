# MegaGirlz (working title)

A side-scrolling, single-player action platformer built in **Godot 4**, in the spirit of Mega Man. The player controls a team of three robotic sisters, **Gigi**, **Evie**, and **Lucy**, swapping between them on the fly to use each one's unique ability. Local co-op may come later.

## Concept

The sisters fight through a series of stages to recover something lost (story TBD). One sister is on stage at a time; the player swaps instantly to whichever sister's ability fits the moment, so combat and traversal reward combining their abilities.

| Sister | Ability | Signature color (placeholder) |
|---|---|---|
| Gigi | Sword; dash (ability button) | Cyan |
| Evie | Shuriken (ranged); slide (ability button) | Magenta |
| Lucy | Sword; double jump, then attack for a smash (plunge + shockwave) | Amber |

Abilities are not designed yet. They will be tuned to fit each sister's personality. Each sister has her own palette and an emissive element (core, visor, or arm cannon) in her signature color, so the player always knows who is on stage. The prototype uses one base sprite (the Magic Cliffs heroine) recolored per sister: outfit and sword slash in her signature color, plus her own hair color. Distinct hairstyles per sister are a planned art pass.

## Core design decisions

- **Side-scrolling action platformer.** Run, jump, and fight with a sword, closer to *Mega Man Zero* than classic Mega Man. Each sister's unique ability adds her ranged or movement option.
- **Single player with instant sister swapping.** Swapping is the core mechanic: the next sister appears in place, keeping position and momentum (even mid-jump), with a short teleport-beam flash.
- **Local co-op deferred, not ruled out.** Input already goes through a per-player layer and characters are decoupled from who controls them, so 2–3 player co-op on one shared screen can be added later without a rewrite. No online multiplayer and no split-screen.
- **Fixed-screen and horizontal scrolling sections.** Stages mix screen-sized rooms with scrolling sections, like Mega Man. Scrolling sections show off layered parallax backgrounds (`Parallax2D`). The camera scrolls in whole pixels and never zooms (zooming makes pixel art shimmer).
- **Modern pixel art.** Detailed sprites combined with modern effects: HDR glow, dynamic 2D lights, particles, and parallax backgrounds (think *Dead Cells*, *Katana Zero*). Prototype with free/CC0 packs; final heroes likely commissioned.
- **Game feel is a priority.** Hit-stop, screen shake, hit flash, squash and stretch, slash effects, and particle effects are core features, not polish.
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
- Input: keyboard or game controller (per-player input layer, ready for co-op later)

## Roadmap

### Milestone 1: Vertical slice
1. One sister running, jumping, and shooting in a test room, with keyboard input and placeholder CC0 art.
2. Game feel pass on the basics: screen shake, muzzle flash, shot impact sparks, jump and land squash and stretch.
3. Sister swapping: three sisters, instant swap with a beam flash, per-sister palettes.
4. Controller support for the single player (auto-detect the first connected controller).
5. Camera: horizontal scrolling sections (done in the Magic Cliffs stage) and fixed-screen rooms with transitions.
6. Visual pass: HDR glow, one dynamic light, parallax background. (Done: glow on slashes, beams, afterimages, sparks, and shuriken, which also carry a light. Desktop only; the web build has no glow.)
7. One enemy type (with hit flash and hit-stop) and each sister's signature ability.

### Later
- Health, damage, and respawn
- Local co-op for 2–3 players (drop-in/drop-out, catch-up rule for players left behind)
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
  projectiles/
  vfx/
  ui/
scripts/
  characters/
  components/     # reusable child-node components
  levels/
  projectiles/
  systems/        # input, swapping, camera, game state
licenses/
CREDITS.md
```

## Getting started

1. Install Godot 4.7 or newer (stable, standard build, not .NET).
2. Clone the repo and open `project.godot` in Godot.
3. Press F5 to run. The entry scene is `scenes/levels/magic_cliffs.tscn`, a horizontal scrolling stage with parallax layers. `scenes/levels/test_room.tscn` is a single-screen room for testing mechanics (open it and press F6).

Prototype controls (keyboard): move **A/D** or **arrows**, jump **Space/K/Z** (hold for a higher jump), attack **J/X** (Gigi and Lucy: sword slash, overhead slash in the air; Evie: throws shuriken, up to 3 in flight), ability **Shift/L** (Gigi: dash, once per jump in the air; Evie: slide, low and under gaps; Lucy's double jump is a second jump press in mid-air, and attacking after it smashes down), swap sister **E/O** (next) and **Q/U** (previous). Controller bindings: A jump, X attack, B ability, RB/LB swap.

Movement feel is tuned through `@export` values on the `Sister` node (Inspector panel): run speed, jump height, time to apex, coyote time, jump buffer, max shots.

## Running tests

Headless tests live in `tests/`. From the project folder:

```
godot --headless --import --path .
godot --headless --path . -s res://tests/run_tests.gd
```

The first command imports the project (needed once after cloning or adding files). The runner executes every `test_*` method in `tests/test_*.gd` and exits with code 1 if any check fails. Shared helpers (`TestContext`: checks, rooms, fake keyboard and controller input) are in `tests/support/`. On Windows, `godot` is the `*_console.exe` build.

`project.godot` already sets the pixel-art defaults: 480×270 viewport, `viewport` stretch mode with integer scaling, nearest-neighbor texture filtering, 2D pixel snapping, and HDR 2D on the Forward+ renderer. Change them only in Project Settings, not by hand-editing the file.
