class_name SisterAbility
extends Node
## Base for a sister's signature ability. Add one ability as a direct child
## of a Sister; she calls these hooks from her physics step, so abilities run
## in a fixed order relative to her own movement.

var body: Sister


func _ready() -> void:
	body = get_parent() as Sister


## Runs before the sister's normal movement each physics frame. Return true
## while the ability controls movement; she then skips gravity, running, and
## jumping that frame.
func process_movement(_delta: float) -> bool:
	return false


## Called when jump is pressed but a normal jump isn't possible. Return true
## if the ability jumped.
func try_air_jump() -> bool:
	return false


## Called when attack is pressed. Return true if the ability handled it; the
## sister then does no normal attack (e.g. Lucy's smash).
func try_attack() -> bool:
	return false


## Animation to show instead of the movement animation, or empty for none.
func get_animation_override() -> StringName:
	return &""


## Called when the sister leaves the stage (swapped out).
func cancel() -> void:
	pass
