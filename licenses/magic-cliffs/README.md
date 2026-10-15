# Magic Cliffs asset pack

- **Author:** Luis Zuno (ansimuz)
- **Source:** ansimuz.itch.io (Magic Cliffs Environment, Godot edition), downloaded October 2026
- **License:** personal and commercial use, modification, and redistribution allowed; credit not required but appreciated. See `public-license.txt` (copied unchanged from the pack).

Files used from the pack (renamed to snake_case where needed):

| Pack path | Repo path |
|---|---|
| `World/tileset.png` | `assets/tiles/magic_cliffs/tileset.png` |
| `World/world-tileset.tres` | `assets/tiles/magic_cliffs/magic_cliffs_tileset.tres` (texture path updated) |
| `World/sky.png`, `clouds.png`, `sea.png`, `far-grounds.png` | `assets/backgrounds/magic_cliffs/` |
| `Player/spritesheets/*.png` | `assets/characters/sister_base/` (recolored per sister by a shader) |
| (built from the sheets above) | `assets/characters/sister_base/sister_base.aseprite`: all frames with one tag per animation, for editing |
| `Enemies/ShurikenDude/Shuriken/shuriken.png` | `assets/projectiles/shuriken.png` (Evie's thrown star) |
| (derived from the sheets above) | `assets/characters/evie/bangs/`: Evie's bangs overlay, also the `evie bangs` layer in the .aseprite file |
| `World/world.tscn` (tile layout only) | `scenes/levels/magic_cliffs.tscn` (converted to `TileMapLayer` and `Parallax2D`) |

Not in the repo yet: enemies (fox, shuriken thrower) and music.
