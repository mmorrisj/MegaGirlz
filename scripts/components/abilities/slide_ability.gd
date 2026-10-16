class_name SlideAbility
extends SisterAbility
## Evie: a fast, low ground slide on the ability button, Mega Man style. Her
## collision is halved so she fits under low gaps (she keeps sliding until
## there's room to stand), and a low hitbox in front of her hits for the whole
## slide. Jumping cancels it.

const DUST_SCENE: PackedScene = preload("res://scenes/vfx/impact_spark.tscn")

@export var slide_speed: float = 260.0
@export var slide_time: float = 0.35
## Wait after a slide ends before the next one.
@export var cooldown: float = 0.15
## Fraction of her normal collision height while sliding.
@export_range(0.2, 1.0) var crouch_height: float = 0.5
## Above 1.0 so afterimages glow with HDR glow; matches Gigi's dash.
@export var afterimage_brightness: float = 1.9
@export var afterimage_interval: float = 0.05
## How much brighter she is while sliding (1.0 = unchanged). Kept neutral:
## tinting her in her color shifts her hair and skin to odd hues.
@export var slide_glow: float = 1.1

## The slide pose sits higher in its frame than her standing feet do.
const POSE_DROP: float = 12.0

var _slide_left: float = 0.0
var _cooldown_left: float = 0.0
var _afterimage_timer: float = 0.0
var _hitbox: Area2D
var _standing_height: float = 0.0


func _ready() -> void:
	super()
	_hitbox = Area2D.new()
	_hitbox.name = "SlideHitbox"
	_hitbox.collision_layer = 8  # player_attacks
	_hitbox.collision_mask = 4  # enemies
	_hitbox.monitoring = false
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(26, 16)
	shape.shape = rect
	# Low and in front: her feet are 20 px below the body's origin.
	shape.position = Vector2(12, 12)
	_hitbox.add_child(shape)
	# The sister sets up her own node references after her children are
	# ready, so attach once she is.
	_attach_hitbox.call_deferred()


func _attach_hitbox() -> void:
	# Under Visual so it flips with her facing.
	body.get_sprite().get_parent().add_child(_hitbox)


func is_sliding() -> bool:
	return _slide_left > 0.0


func get_slide_hitbox() -> Area2D:
	return _hitbox


func process_movement(delta: float) -> bool:
	_cooldown_left -= delta
	var input: PlayerInput = body.input
	if is_sliding():
		_slide_left -= delta
		if input and input.is_jump_just_pressed() and _has_headroom():
			_end_slide()
			return false
		if not body.is_on_floor():
			_end_slide()
			return false
		if _slide_left <= 0.0:
			if _has_headroom():
				_end_slide()
				return false
			# Still under something low: keep sliding until she can stand.
			_slide_left = 0.05
		body.velocity = Vector2(body.facing * slide_speed, 10.0)
		_afterimage_timer -= delta
		if _afterimage_timer <= 0.0:
			_afterimage_timer = afterimage_interval
			Afterimage.spawn(body, afterimage_brightness, 0.15)
		return true
	if input == null or not input.is_ability_just_pressed():
		return false
	if _cooldown_left > 0.0 or not body.is_on_floor():
		return false
	_start_slide()
	return true


## Attacks are swallowed while sliding: the slide is her attack.
func try_attack() -> bool:
	return is_sliding()


func get_animation_override() -> StringName:
	return &"slide" if is_sliding() else &""


func cancel() -> void:
	if is_sliding():
		_end_slide()


func _start_slide() -> void:
	_slide_left = slide_time
	_cooldown_left = slide_time + cooldown
	# The first afterimage waits a beat: on this frame she still has her
	# standing pose.
	_afterimage_timer = afterimage_interval
	var collision: CollisionShape2D = body.get_collision_shape()
	_standing_height = (collision.shape as RectangleShape2D).size.y
	# Shrink from the top, keeping her feet on the ground.
	collision.scale.y = crouch_height
	collision.position.y = _standing_height * (1.0 - crouch_height) * 0.5
	body.get_sprite().offset.y = POSE_DROP
	body.get_sprite().self_modulate = Color(slide_glow, slide_glow, slide_glow)
	_hitbox.monitoring = true
	body.velocity = Vector2(body.facing * slide_speed, 10.0)
	_spawn_dust()


func _end_slide() -> void:
	_slide_left = 0.0
	var collision: CollisionShape2D = body.get_collision_shape()
	collision.scale.y = 1.0
	collision.position.y = 0.0
	body.get_sprite().offset.y = 0.0
	body.get_sprite().self_modulate = Color.WHITE
	_hitbox.monitoring = false


## True when there is room above her to stand up at full height.
func _has_headroom() -> bool:
	var rise: float = _standing_height * (1.0 - crouch_height)
	return not body.test_move(body.global_transform, Vector2(0, -rise))


func _spawn_dust() -> void:
	var dust: CPUParticles2D = DUST_SCENE.instantiate()
	dust.color = Color(0.85, 0.8, 0.65)
	dust.direction = Vector2(-body.facing, -0.4)
	dust.spread = 30.0
	dust.gravity = Vector2(0, 200)
	dust.amount = 10
	dust.initial_velocity_min = 40.0
	dust.initial_velocity_max = 90.0
	dust.scale_amount_min = 1.0
	dust.scale_amount_max = 2.0
	body.get_parent().add_child(dust)
	dust.global_position = body.global_position + Vector2(0, 18)
