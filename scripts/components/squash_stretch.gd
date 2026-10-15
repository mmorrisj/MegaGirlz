class_name SquashStretch
extends Node
## Squashes and stretches a visual node on jump and landing, then springs back.
##
## Point `target` at a pivot placed at the character's feet so the sprite
## stays planted on the ground while it squashes.

@export var target: Node2D
@export var jump_stretch: Vector2 = Vector2(0.75, 1.25)
@export var land_squash: Vector2 = Vector2(1.3, 0.7)
## Fall speed that produces the full land squash.
@export var max_land_speed: float = 420.0
## Landings slower than this fraction of max_land_speed play no squash.
@export_range(0.0, 1.0) var min_land_fraction: float = 0.2
@export var recover_time: float = 0.15

var _tween: Tween


func play_jump() -> void:
	_pop(jump_stretch)


func play_land(fall_speed: float) -> void:
	var strength: float = clampf(fall_speed / max_land_speed, 0.0, 1.0)
	if strength < min_land_fraction:
		return
	_pop(Vector2.ONE.lerp(land_squash, strength))


func _pop(pop_scale: Vector2) -> void:
	if _tween:
		_tween.kill()
	target.scale = pop_scale
	_tween = create_tween()
	_tween.tween_property(target, "scale", Vector2.ONE, recover_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
