class_name SisterAnimator
extends Node
## Picks the sister's animation from how she is moving.
##
## A sword slash (ground or air) plays to the end over any movement
## animation. Runs after the sister in each physics frame (children process
## after their parent), so it always sees her latest velocity and floor state.

@export var body: Sister
@export var sprite: AnimatedSprite2D


func play_attack() -> void:
	_restart(&"attack")


func play_air_attack() -> void:
	_restart(&"air_slash")


func _restart(animation: StringName) -> void:
	sprite.play(animation)
	sprite.set_frame_and_progress(0, 0.0)


func _physics_process(_delta: float) -> void:
	if body.is_attacking():
		return
	if not body.is_on_floor():
		_play(&"jump" if body.velocity.y < 0.0 else &"fall")
	elif not is_zero_approx(body.velocity.x):
		_play(&"run")
	else:
		_play(&"idle")


func _play(animation: StringName) -> void:
	if sprite.animation != animation:
		sprite.play(animation)
