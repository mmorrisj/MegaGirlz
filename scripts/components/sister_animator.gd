class_name SisterAnimator
extends Node
## Picks the sister's animation from how she is moving.
##
## Firing holds an arm-out pose for a moment, Mega Man style. Runs after the
## sister in each physics frame (children process after their parent), so it
## always sees her latest velocity and floor state.

const RUN_ANIMATIONS: Array[StringName] = [&"run", &"run_shoot"]

@export var body: CharacterBody2D
@export var sprite: AnimatedSprite2D
## How long the arm-out pose lasts after a shot.
@export var shoot_pose_time: float = 0.25

var _shoot_pose_timer: float = 0.0


func play_shoot() -> void:
	_shoot_pose_timer = shoot_pose_time


func _physics_process(delta: float) -> void:
	_shoot_pose_timer = maxf(_shoot_pose_timer - delta, 0.0)
	var shooting: bool = _shoot_pose_timer > 0.0
	if not body.is_on_floor():
		# The placeholder art has no jump-and-shoot frame.
		_play(&"jump")
	elif not is_zero_approx(body.velocity.x):
		_play(&"run_shoot" if shooting else &"run")
	else:
		_play(&"shoot" if shooting else &"idle")


func _play(animation: StringName) -> void:
	if sprite.animation == animation and sprite.is_playing():
		return
	# Switching between run and run_shoot keeps the stride instead of restarting it.
	var keep_stride: bool = sprite.animation in RUN_ANIMATIONS and animation in RUN_ANIMATIONS
	var frame: int = sprite.frame
	var progress: float = sprite.frame_progress
	sprite.play(animation)
	if keep_stride:
		sprite.set_frame_and_progress(frame, progress)
