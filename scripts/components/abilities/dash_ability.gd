class_name DashAbility
extends SisterAbility
## Gigi: a fast horizontal dash on the ability button, leaving afterimages in
## her color. Gravity pauses while dashing; it works once per jump in the air,
## and jumping cancels it.

const SILHOUETTE_SHADER: Shader = preload("res://assets/vfx/silhouette.gdshader")

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
var _afterimage_material: ShaderMaterial


func _ready() -> void:
	super()
	_afterimage_material = ShaderMaterial.new()
	_afterimage_material.shader = SILHOUETTE_SHADER


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
	var sprite: AnimatedSprite2D = body.get_sprite()
	var ghost := Sprite2D.new()
	ghost.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	ghost.material = _afterimage_material
	var color: Color = body.signature_color
	var b: float = afterimage_brightness
	ghost.modulate = Color(color.r * b, color.g * b, color.b * b, 0.7)
	# Added to the level so the trail stays where she was, just before her in
	# the tree so it draws behind her but in front of the level art.
	body.get_parent().add_child(ghost)
	body.get_parent().move_child(ghost, body.get_index())
	ghost.global_transform = sprite.global_transform
	var tween: Tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, afterimage_fade)
	tween.tween_callback(ghost.queue_free)
