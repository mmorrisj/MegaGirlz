class_name Sister
extends CharacterBody2D
## A playable sister: run, jump, and shoot.
##
## Shared by Gigi, Evie, and Lucy. Each sister's signature ability will be a
## separate child component, not a subclass. Game-feel effects listen to
## this node's signals instead of living in this script.

signal jumped
## fall_speed is the downward speed just before touching the ground.
signal landed(fall_speed: float)
signal shot_fired
## Emitted when this sister takes over from another during a swap.
signal swapped_in

const BUSTER_SHOT_SCENE: PackedScene = preload("res://scenes/projectiles/buster_shot.tscn")

## Identifies this sister: drives her sprite palette and swap beam, and
## becomes her emissive color once real art exists.
@export var signature_color: Color = Color.CYAN

@export_group("Run")
@export var run_speed: float = 140.0

@export_group("Jump")
## Peak height of a full (held) jump, in pixels.
@export var jump_height: float = 72.0
## Seconds from takeoff to the peak of a full jump.
@export var time_to_apex: float = 0.35
@export var fall_gravity_multiplier: float = 1.3
@export var max_fall_speed: float = 420.0
## Upward speed is multiplied by this when jump is released early.
@export_range(0.0, 1.0) var jump_cut_multiplier: float = 0.4
## Grace period to still jump after walking off a ledge.
@export var coyote_time: float = 0.08
## A jump pressed this long before landing still fires on landing.
@export var jump_buffer_time: float = 0.1

@export_group("Shoot")
## Mega Man style limit on shots alive at once.
@export var max_shots: int = 3
@export var muzzle_offset: Vector2 = Vector2(15.0, -5.0)

## The player controlling this sister. Null means no one (she stands still).
var input: PlayerInput = null
## 1 = facing right, -1 = facing left.
var facing: int = 1

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _is_rising_from_jump: bool = false
var _live_shots: int = 0

@onready var _visual: Node2D = $SquashPivot/Visual
@onready var _sprite: AnimatedSprite2D = $SquashPivot/Visual/Sprite
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _swap_beam: SwapBeam = $SquashPivot/Visual/SwapBeam


func _ready() -> void:
	_apply_palette()
	_swap_beam.set_color(signature_color)


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_apply_gravity(delta)
	if input:
		_handle_run()
		_handle_jump()
		_handle_shoot()
	else:
		velocity.x = 0.0
	var was_on_floor: bool = is_on_floor()
	var fall_speed: float = velocity.y
	move_and_slide()
	if is_on_floor() and not was_on_floor:
		landed.emit(fall_speed)


## Puts this sister on stage (visible, colliding, processing) or takes her off.
func set_active(active: bool) -> void:
	visible = active
	process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
	_collision.disabled = not active
	if not active:
		input = null


## Steps in where `other` stands, keeping her motion so swaps work mid-jump.
func take_over_from(other: Sister) -> void:
	global_position = other.global_position
	velocity = other.velocity
	_set_facing(other.facing)
	_is_rising_from_jump = other._is_rising_from_jump
	_coyote_timer = other._coyote_timer
	swapped_in.emit()


func _apply_palette() -> void:
	var palette := _sprite.material as ShaderMaterial
	if palette == null:
		return
	palette.set_shader_parameter(&"target_main", signature_color)
	palette.set_shader_parameter(&"target_shade", signature_color.darkened(0.45))
	palette.set_shader_parameter(&"target_accent", signature_color.lightened(0.6))


func _set_facing(direction: int) -> void:
	facing = direction
	_visual.scale.x = direction


func _get_rise_gravity() -> float:
	return 2.0 * jump_height / (time_to_apex * time_to_apex)


func _get_jump_velocity() -> float:
	return 2.0 * jump_height / time_to_apex


func _update_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer -= delta
	_jump_buffer_timer -= delta


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		_is_rising_from_jump = false
		return
	var gravity: float = _get_rise_gravity()
	if velocity.y > 0.0:
		gravity *= fall_gravity_multiplier
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	if velocity.y >= 0.0:
		_is_rising_from_jump = false


func _handle_run() -> void:
	var axis: float = input.get_move_axis()
	# Digital, Mega Man style: full speed or none, even on an analog stick.
	velocity.x = signf(axis) * run_speed
	if axis != 0.0:
		_set_facing(int(signf(axis)))


func _handle_jump() -> void:
	if input.is_jump_just_pressed():
		_jump_buffer_timer = jump_buffer_time
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = -_get_jump_velocity()
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_is_rising_from_jump = true
		jumped.emit()
	elif _is_rising_from_jump and not input.is_jump_held():
		velocity.y *= jump_cut_multiplier
		_is_rising_from_jump = false


func _handle_shoot() -> void:
	if not input.is_shoot_just_pressed() or _live_shots >= max_shots:
		return
	var shot: BusterShot = BUSTER_SHOT_SCENE.instantiate()
	shot.direction = facing
	# Added to the room, not to us, so it keeps flying if we are swapped out.
	get_parent().add_child(shot)
	shot.global_position = global_position + Vector2(muzzle_offset.x * facing, muzzle_offset.y)
	_live_shots += 1
	shot.tree_exited.connect(_on_shot_tree_exited)
	shot_fired.emit()


func _on_shot_tree_exited() -> void:
	_live_shots -= 1
