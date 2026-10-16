class_name DoubleJumpAbility
extends SisterAbility
## Lucy: extra jumps in mid-air, each with a puff in her color. They refill
## when she lands.

const PUFF_SCENE: PackedScene = preload("res://scenes/vfx/impact_spark.tscn")

@export var air_jumps: int = 1
## Height of an air jump relative to a full ground jump.
@export_range(0.1, 1.5) var height_scale: float = 0.85

var _air_jumps_left: int = 0


func process_movement(_delta: float) -> bool:
	if body.is_on_floor():
		_air_jumps_left = air_jumps
	return false


func try_air_jump() -> bool:
	if _air_jumps_left <= 0:
		return false
	_air_jumps_left -= 1
	body.perform_jump(height_scale)
	_spawn_puff()
	return true


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
