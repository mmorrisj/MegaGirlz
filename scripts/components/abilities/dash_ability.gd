class_name DashAbility
extends SisterAbility
## Gigi: a fast horizontal dash on the ability button, leaving afterimages in
## her color. Gravity pauses while dashing; it works once per jump in the air,
## and jumping cancels it.

@export var dash_speed: float = 330.0
@export var dash_time: float = 0.18
## Wait after a dash ends before the next one.
@export var cooldown: float = 0.25
@export var afterimage_interval: float = 0.03
@export var afterimage_fade: float = 0.2
## Above 1.0 so afterimages glow with HDR glow.
@export var afterimage_brightness: float = 1.9
## How much brighter she is while dashing (1.0 = unchanged). Kept neutral:
## tinting her in her color shifts her hair and skin to odd hues.
@export var dash_glow: float = 1.1

var _dash_left: float = 0.0
var _cooldown_left: float = 0.0
var _air_dash_used: bool = false
var _afterimage_timer: float = 0.0


func is_dashing() -> bool:
	return _dash_left > 0.0


func process_movement(delta: float) -> bool:
	_cooldown_left -= delta
	if body.is_on_floor():
		_air_dash_used = false
	var input: PlayerInput = body.input
	if is_dashing():
		if input and input.is_jump_just_pressed():
			cancel()
			return false
		_dash_left -= delta
		if _dash_left <= 0.0:
			cancel()
			return false
		body.velocity = Vector2(body.facing * dash_speed, 0.0)
		_afterimage_timer -= delta
		if _afterimage_timer <= 0.0:
			_spawn_afterimage()
		return true
	if input == null or not input.is_ability_just_pressed() or _cooldown_left > 0.0:
		return false
	if not body.is_on_floor():
		if _air_dash_used:
			return false
		_air_dash_used = true
	_dash_left = dash_time
	_cooldown_left = dash_time + cooldown
	body.velocity = Vector2(body.facing * dash_speed, 0.0)
	_set_glowing(true)
	_spawn_afterimage()
	return true


func get_animation_override() -> StringName:
	return &"dash" if is_dashing() else &""


func cancel() -> void:
	_dash_left = 0.0
	_set_glowing(false)


func _set_glowing(glowing: bool) -> void:
	var glow := Color(dash_glow, dash_glow, dash_glow)
	body.get_sprite().self_modulate = glow if glowing else Color.WHITE


func _spawn_afterimage() -> void:
	_afterimage_timer = afterimage_interval
	Afterimage.spawn(body, afterimage_brightness, afterimage_fade)
