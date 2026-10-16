class_name DoubleJumpAbility
extends SisterAbility
## Lucy: extra jumps in mid-air, each with a puff in her color; they refill
## when she lands. Attacking after an air jump starts a smash: she plunges
## straight down and hits the ground with a glowing shockwave.

## Emitted when a smash hits the ground.
signal smashed

const PUFF_SCENE: PackedScene = preload("res://scenes/vfx/impact_spark.tscn")
const SHOCKWAVE_SCENE: PackedScene = preload("res://scenes/vfx/shockwave.tscn")

@export var air_jumps: int = 1
## Height of an air jump relative to a full ground jump.
@export_range(0.1, 1.5) var height_scale: float = 0.85

@export_group("Smash")
@export var smash_speed: float = 520.0
## Screen-shake trauma on impact.
@export_range(0.0, 1.0) var smash_shake: float = 0.6
## How long the impact hitbox stays live.
@export var smash_hit_time: float = 0.12
@export var smash_hit_radius: float = 36.0
## She holds the chop pose, frozen, this long after impact to sell the weight.
@export var smash_recovery: float = 0.2
@export var afterimage_brightness: float = 1.9

var _air_jumps_left: int = 0
## True from an air jump until she lands: the window for a smash.
var _used_air_jump: bool = false
var _smashing: bool = false
var _hit_time_left: float = 0.0
var _recovery_left: float = 0.0
var _afterimage_timer: float = 0.0
var _hitbox: Area2D


func _ready() -> void:
	super()
	_hitbox = Area2D.new()
	_hitbox.name = "SmashHitbox"
	_hitbox.collision_layer = 8  # player_attacks
	_hitbox.collision_mask = 4  # enemies
	_hitbox.monitoring = false
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = smash_hit_radius
	shape.shape = circle
	# Centered just above her feet (the body's origin is 20 px above them).
	shape.position = Vector2(0, 14)
	_hitbox.add_child(shape)
	# The sister is still adding her children while this runs.
	body.add_child.call_deferred(_hitbox)


func is_smashing() -> bool:
	return _smashing


func get_smash_hitbox() -> Area2D:
	return _hitbox


func process_movement(delta: float) -> bool:
	if _hit_time_left > 0.0:
		_hit_time_left -= delta
		if _hit_time_left <= 0.0:
			_hitbox.monitoring = false
	if _recovery_left > 0.0:
		_recovery_left -= delta
		body.velocity = Vector2.ZERO
		return true
	if body.is_on_floor():
		_air_jumps_left = air_jumps
		_used_air_jump = false
		if _smashing:
			_impact()
			return true
		return false
	if not _smashing:
		return false
	body.velocity = Vector2(0.0, smash_speed)
	_afterimage_timer -= delta
	if _afterimage_timer <= 0.0:
		_afterimage_timer = 0.03
		Afterimage.spawn(body, afterimage_brightness, 0.2)
	return true


func try_air_jump() -> bool:
	if _air_jumps_left <= 0 or _smashing:
		return false
	_air_jumps_left -= 1
	_used_air_jump = true
	body.perform_jump(height_scale)
	_spawn_puff()
	return true


func try_attack() -> bool:
	if _smashing or body.is_on_floor() or not _used_air_jump:
		return false
	_smashing = true
	_afterimage_timer = 0.0
	body.velocity = Vector2(0.0, smash_speed)
	body.get_sprite().self_modulate = Color(1.1, 1.1, 1.1)
	return true


func get_animation_override() -> StringName:
	return &"smash" if _smashing or _recovery_left > 0.0 else &""


func cancel() -> void:
	_smashing = false
	_hit_time_left = 0.0
	_recovery_left = 0.0
	_hitbox.monitoring = false
	body.get_sprite().self_modulate = Color.WHITE


func _impact() -> void:
	_smashing = false
	_recovery_left = smash_recovery
	body.velocity = Vector2.ZERO
	body.get_sprite().self_modulate = Color.WHITE
	var feet: Vector2 = body.global_position + Vector2(0, 20)
	var level: Node = body.get_parent()
	var wave: Shockwave = SHOCKWAVE_SCENE.instantiate()
	wave.set_color(body.signature_color)
	level.add_child(wave)
	wave.global_position = feet
	var color: Color = body.signature_color
	for side in [-1.0, 1.0]:
		var spark: CPUParticles2D = PUFF_SCENE.instantiate()
		spark.direction = Vector2(side, -0.7)
		spark.spread = 25.0
		spark.amount = 14
		spark.initial_velocity_min = 90.0
		spark.initial_velocity_max = 180.0
		spark.scale_amount_min = 2.0
		spark.scale_amount_max = 3.0
		spark.color = Color(color.r * 2.0, color.g * 2.0, color.b * 2.0)
		level.add_child(spark)
		spark.global_position = feet
	ShakeCamera.shake(get_tree(), smash_shake)
	_hitbox.monitoring = true
	_hit_time_left = smash_hit_time
	smashed.emit()


func _spawn_puff() -> void:
	var puff: CPUParticles2D = PUFF_SCENE.instantiate()
	# Her own color, slightly boosted: lightening it washes out against the sky.
	var color: Color = body.signature_color
	puff.color = Color(color.r * 1.2, color.g * 1.2, color.b * 1.2)
	puff.direction = Vector2.DOWN
	puff.spread = 80.0
	puff.gravity = Vector2.ZERO
	puff.amount = 12
	puff.scale_amount_min = 2.0
	puff.scale_amount_max = 3.0
	body.get_parent().add_child(puff)
	# At her feet: the body's origin is its center, 20 px above the feet.
	puff.global_position = body.global_position + Vector2(0, 20)
