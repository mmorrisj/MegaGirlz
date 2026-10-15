class_name ShakeCamera
extends Camera2D
## Camera with trauma-based screen shake.
##
## Anything can shake the active camera without holding a reference to it:
## ShakeCamera.shake(get_tree(), 0.3)

const GROUP: StringName = &"shake_camera"

## Offset in pixels at full trauma.
@export var max_offset: Vector2 = Vector2(8.0, 6.0)
## Trauma lost per second.
@export var decay: float = 2.5

## 0.0 (still) to 1.0 (maximum shake).
var _trauma: float = 0.0


static func shake(tree: SceneTree, amount: float) -> void:
	tree.call_group(GROUP, "add_trauma", amount)


func _ready() -> void:
	add_to_group(GROUP)


func add_trauma(amount: float) -> void:
	_trauma = minf(_trauma + amount, 1.0)


func _process(delta: float) -> void:
	if _trauma <= 0.0:
		offset = Vector2.ZERO
		return
	_trauma = maxf(_trauma - decay * delta, 0.0)
	# Squared so small hits stay subtle and big hits feel violent.
	var strength: float = _trauma * _trauma
	var jitter := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	# Whole pixels only, so pixel art never renders between pixels.
	offset = (max_offset * jitter * strength).round()
