class_name Sister
extends CharacterBody2D
## A playable sister: run, jump, and fight with her weapon (sword or shuriken).
##
## Shared by Gigi, Evie, and Lucy. Each sister's signature ability is a
## SisterAbility child component (e.g. Gigi's dash), not a subclass. Game-feel effects listen to
## this node's signals instead of living in this script.

signal jumped
## fall_speed is the downward speed just before touching the ground.
signal landed(fall_speed: float)
## Emitted when a ground sword slash starts.
signal attacked
## Emitted when an overhead slash starts in the air.
signal air_attacked
## Emitted when a shuriken is thrown.
signal threw
## Emitted when this sister takes over from another during a swap.
signal swapped_in

enum Weapon { SWORD, SHURIKEN }
enum AttackKind { GROUND, AIR, THROW }

## Identifies this sister: her outfit, sword slash, and swap beam use it.
@export var signature_color: Color = Color.CYAN
## Lightest hair shade; darker shades are derived from it. The boots share
## the hair colors in the base sprite.
@export var hair_color: Color = Color(1.0, 0.663, 0.224)
## Brightness of her colored sword slash; above 1.0 it glows.
@export var slash_glow: float = 2.6
## Optional art drawn over the shared sprite to give this sister her own look
## (e.g. Evie's bangs). Must mirror the base sprite's animations and frames.
@export var hairstyle_frames: SpriteFrames
## Sword: ground slash and overhead air slash. Shuriken: thrown stars, on the
## ground or in the air.
@export var weapon: Weapon = Weapon.SWORD

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

@export_group("Air attack")
## Overhead slash used when attacking in the air. Landing cuts it short.
@export var air_attack_duration: float = 0.32
@export var air_attack_active_start: float = 0.08
@export var air_attack_active_end: float = 0.24

@export_group("Throw")
## How long the throwing pose holds before she can throw again.
@export var throw_duration: float = 0.2

## The player controlling this sister. Null means no one (she stands still).
var input: PlayerInput = null
## 1 = facing right, -1 = facing left.
var facing: int = 1

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _is_rising_from_jump: bool = false
## Which slash is playing; only meaningful while is_attacking().
var attack_kind: AttackKind = AttackKind.GROUND

## Seconds since the current slash started, or -1 when not attacking.
var _attack_time: float = -1.0
## This sister's signature ability, if she has one (a SisterAbility child).
var _ability: SisterAbility = null

@onready var _visual: Node2D = $SquashPivot/Visual
@onready var _sprite: AnimatedSprite2D = $SquashPivot/Visual/Sprite
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _swap_beam: SwapBeam = $SquashPivot/Visual/SwapBeam
@onready var _sword_hitbox: Area2D = $SquashPivot/Visual/SwordHitbox
@onready var _air_slash_hitbox: Area2D = $SquashPivot/Visual/AirSlashHitbox
@onready var _slash_arc: SlashArc = $SquashPivot/Visual/SlashArc
@onready var _hairstyle: SpriteOverlay = $SquashPivot/Visual/Hairstyle
@onready var _thrower: ShurikenThrower = $SquashPivot/Visual/ShurikenThrower


func _ready() -> void:
	_apply_palette()
	_swap_beam.set_color(signature_color)
	_slash_arc.set_color(signature_color)
	_hairstyle.sprite_frames = hairstyle_frames
	_hairstyle.visible = hairstyle_frames != null
	_hairstyle.sync()
	for child in get_children():
		if child is SisterAbility:
			_ability = child


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	var ability_moving: bool = _ability != null and _ability.process_movement(delta)
	if not ability_moving:
		_apply_gravity(delta)
	_update_attack(delta)
	if input:
		if not ability_moving:
			_handle_run()
			_handle_jump()
		_handle_attack()
	elif not ability_moving:
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
		if _ability:
			_ability.cancel()


func is_attacking() -> bool:
	return _attack_time >= 0.0


func get_sprite() -> AnimatedSprite2D:
	return _sprite


## Animation the ability wants shown instead of movement (e.g. the dash pose),
## or empty.
func get_ability_animation() -> StringName:
	return _ability.get_animation_override() if _ability else &""


## Jumps straight up. height_scale 1.0 is a full jump; holding jump still
## controls the height.
func perform_jump(height_scale: float) -> void:
	velocity.y = -_get_jump_velocity() * sqrt(height_scale)
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_is_rising_from_jump = true
	jumped.emit()


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
	palette.set_shader_parameter(&"slash_glow", slash_glow)


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
		perform_jump(1.0)
	elif input.is_jump_just_pressed() and _ability and _ability.try_air_jump():
		pass
	elif _is_rising_from_jump and not input.is_jump_held():
		velocity.y *= jump_cut_multiplier
		_is_rising_from_jump = false


func _handle_attack() -> void:
	if not input.is_attack_just_pressed() or is_attacking():
		return
	if weapon == Weapon.SHURIKEN:
		if not _thrower.can_throw():
			return
		_attack_time = 0.0
		attack_kind = AttackKind.THROW
		_thrower.throw(facing)
		threw.emit()
		return
	_attack_time = 0.0
	if is_on_floor():
		attack_kind = AttackKind.GROUND
		attacked.emit()
	else:
		attack_kind = AttackKind.AIR
		air_attacked.emit()


func _update_attack(delta: float) -> void:
	if not is_attacking():
		return
	if attack_kind == AttackKind.AIR and is_on_floor():
		_end_attack()
		return
	_attack_time += delta
	match attack_kind:
		AttackKind.GROUND:
			_update_slash(attack_duration, attack_active_start, attack_active_end, _sword_hitbox)
		AttackKind.AIR:
			_update_slash(air_attack_duration, air_attack_active_start, air_attack_active_end, _air_slash_hitbox)
		AttackKind.THROW:
			if _attack_time >= throw_duration:
				_end_attack()


## Ends the slash after `duration`; the hitbox is live between the two times.
func _update_slash(duration: float, active_start: float, active_end: float, hitbox: Area2D) -> void:
	if _attack_time >= duration:
		_end_attack()
		return
	hitbox.monitoring = _attack_time >= active_start and _attack_time < active_end


func _end_attack() -> void:
	if attack_kind == AttackKind.AIR and is_attacking():
		_slash_arc.stop()
	_attack_time = -1.0
	_sword_hitbox.monitoring = false
	_air_slash_hitbox.monitoring = false
