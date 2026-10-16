class_name Shockwave
extends Node2D
## Ground-impact shockwave: a glowing flattened ring that races outward from
## the impact point, a white core flash, and a burst of light that lights the
## scenery. Frees itself when done. Call set_color() before adding it.

@export var max_radius: float = 64.0
@export var thickness: float = 7.0
## Vertical squash of the ring, so it reads as spreading along the ground.
@export var flatten: float = 0.3
@export var duration: float = 0.35
## Above 1.0 so the ring and flash bloom with HDR glow.
@export var brightness: float = 2.6
@export var flash_brightness: float = 3.0
@export var light_energy: float = 2.5

var _color: Color = Color.WHITE
var _time: float = 0.0

@onready var _light: PointLight2D = $Light


func set_color(color: Color) -> void:
	_color = color


func _ready() -> void:
	_light.color = _color


func _process(delta: float) -> void:
	_time += delta
	var t: float = _time / duration
	if t >= 1.0:
		queue_free()
		return
	_light.energy = light_energy * (1.0 - t)
	queue_redraw()


func _draw() -> void:
	var t: float = clampf(_time / duration, 0.0, 1.0)
	var fade: float = 1.0 - t
	# Core flash: a white burst that shrinks away in the first third.
	if t < 0.33:
		var core: float = 1.0 - t / 0.33
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.6))
		draw_circle(Vector2.ZERO, 16.0 * core, Color(flash_brightness, flash_brightness, flash_brightness, core))
	# Ring: fast at first, slowing as it spreads, thinning as it fades.
	var radius: float = max_radius * ease(t, 0.4)
	var ring := Color(_color.r * brightness, _color.g * brightness, _color.b * brightness, fade)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, flatten))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, ring, thickness * (0.4 + 0.6 * fade))
