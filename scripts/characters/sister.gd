class_name Sister
extends CharacterBody2D
## A playable sister: run, jump, and slash with her sword.
##
## Shared by Gigi, Evie, and Lucy. Each sister's signature ability will be a
## separate child component, not a subclass. Game-feel effects listen to
## this node's signals instead of living in this script.

signal jumped
## fall_speed is the downward speed just before touching the ground.
signal landed(fall_speed: float)
## Emitted when a sword slash starts.
signal attacked
## Emitted when this sister takes over from another during a swap.
signal swapped_in

## Identifies this sister: her outfit, sword slash, and swap beam use it.
@export var signature_color: Color = Color.CYAN
## Lightest hair shade; darker shades are derived from it. The boots share
## the hair colors in the base sprite.
@export var hair_color: Color = Color(1.0, 0.663, 0.224)

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

@export_group("Attack")
## Length of a slash; matches the 8-frame attack animation at 12 fps.
@export var attack_duration: float = 0.66
## Seconds into the slash when the sword starts and stops hitting (the
## frames where the blade sweeps forward).
@export var attack_active_start: float = 0.3
@export var attack_active_end: float = 0.55

## The player controlling this sister. Null means no one (she stands still).
var input: PlayerInput = null
## 1 = facing right, -1 = facing left.
var facing: int = 1

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _is_rising_from_jump: bool = false
## Seconds since the current slash started, or -1 when not attacking.
var _attack_time: float = -1.0

@onready var _visual: Node2D = $SquashPivot/Visual
@onready var _sprite: AnimatedSprite2D = $SquashPivot/Visual/Sprite
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _swap_beam: SwapBeam = $SquashPivot/Visual/SwapBeam
@onready var _sword_hitbox: Area2D = $SquashPivot/Visual/SwordHitbox


func _ready() -> void:
	_apply_palette()
	_swap_beam.set_color(signature_color)


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_apply_gravity(delta)
	_update_attack(delta)
	if input:
		_handle_run()
		_handle_jump()
		_handle_attack()
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
		_end_attack()


func is_attacking() -> bool:
	return _attack_time >= 0.0


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
	palette.set_shader_parameter(&"target_outfit", signature_color)
	palette.set_shader_parameter(&"target_outfit_shade", signature_color.darkened(0.5))
	palette.set_shader_parameter(&"target_hair", hair_color)
	palette.set_shader_parameter(&"target_hair_mid", hair_color.darkened(0.3))
	palette.set_shader_parameter(&"target_hair_dark", hair_color.darkened(0.55))
	palette.set_shader_parameter(&"target_slash", signature_color.lightened(0.45))


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


func _handle_attack() -> void:
	if input.is_attack_just_pressed() and not is_attacking():
		_attack_time = 0.0
		attacked.emit()


func _update_attack(delta: float) -> void:
	if not is_attacking():
		return
	_attack_time += delta
	if _attack_time >= attack_duration:
		_end_attack()
		return
	_sword_hitbox.monitoring = _attack_time >= attack_active_start and _attack_time < attack_active_end


func _end_attack() -> void:
	_attack_time = -1.0
	_sword_hitbox.monitoring = false
