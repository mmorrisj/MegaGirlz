class_name SlashArc
extends Node2D
## Crescent sword trail for the overhead air slash. It sweeps from above the
## head down to the front, then fades. Drawn in code because the base sprite
## has no air-slash art. Place it at the shoulder; it mirrors with facing.

## Distance from the shoulder to the outer edge of the trail.
@export var radius: float = 25.0
## Width of the trail at the blade end; it tapers to nothing at the tail.
@export var thickness: float = 9.0
## Angles in degrees: 0 points forward, -90 straight up.
@export var start_angle: float = -115.0
@export var end_angle: float = 50.0
## Seconds before the sweep starts, to match the wind-up frame.
@export var delay: float = 0.08
@export var sweep_time: float = 0.12
@export var fade_time: float = 0.12
## Above 1.0 so the trail glows once HDR glow is enabled.
@export var brightness: float = 1.6

const SEGMENTS: int = 14

var _edge_color: Color = Color.CYAN
## Seconds since play(), or -1 when idle.
var _time: float = -1.0


func _ready() -> void:
	visible = false


func set_color(color: Color) -> void:
	var tint: Color = color.lightened(0.1)
	_edge_color = Color(tint.r * brightness, tint.g * brightness, tint.b * brightness)


func play() -> void:
	_time = 0.0
	visible = true
	queue_redraw()


func stop() -> void:
	_time = -1.0
	visible = false


func _process(delta: float) -> void:
	if _time < 0.0:
		return
	_time += delta
	if _time > delay + sweep_time + fade_time:
		stop()
		return
	queue_redraw()


func _draw() -> void:
	if _time < delay:
		return
	var sweep: float = ease(clampf((_time - delay) / sweep_time, 0.0, 1.0), 0.5)
	var alpha: float = 1.0 - clampf((_time - delay - sweep_time) / fade_time, 0.0, 1.0)
	var from: float = deg_to_rad(start_angle)
	var to: float = lerpf(from, deg_to_rad(end_angle), sweep)
	var white := Color(brightness, brightness, brightness, alpha)
	_draw_crescent(from, to, radius, thickness, white)
	var edge := _edge_color
	edge.a = alpha
	# Colored inner band, like the pack's own white-and-cyan slash.
	_draw_crescent(from, to, radius - thickness * 0.4, thickness * 0.6, edge)


## A band between two angles that is `width` thick at `to` (the blade) and
## tapers to a point at `from` (the tail).
func _draw_crescent(from: float, to: float, outer: float, width: float, color: Color) -> void:
	if absf(to - from) < 0.01:
		return
	var points := PackedVector2Array()
	for i in SEGMENTS + 1:
		var angle: float = lerpf(from, to, float(i) / SEGMENTS)
		points.append(Vector2.from_angle(angle) * outer)
	for i in range(SEGMENTS, -1, -1):
		var t: float = float(i) / SEGMENTS
		var angle: float = lerpf(from, to, t)
		points.append(Vector2.from_angle(angle) * (outer - width * t))
	draw_colored_polygon(points, color)
