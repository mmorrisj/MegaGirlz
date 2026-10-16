class_name Party
extends Node
## The sisters one player controls. Exactly one is on stage at a time; the
## swap buttons hand control to the next or previous sister, who appears in
## place and keeps the momentum (even mid-jump).
##
## Place this node after the sisters so they are ready before it is.

signal swapped(from: Sister, to: Sister)

@export var members: Array[Sister] = []
@export var player_index: int = 0
## Minimum seconds between swaps, so mashing the button doesn't flicker.
@export var swap_cooldown: float = 0.2

var _active_index: int = 0
var _input: PlayerInput = null
var _cooldown_timer: float = 0.0


func _ready() -> void:
	_input = PlayerManager.get_input(player_index)
	for i in members.size():
		members[i].set_active(i == _active_index)
	get_active().input = _input


func get_active() -> Sister:
	return members[_active_index]


func _physics_process(delta: float) -> void:
	_cooldown_timer -= delta
	if _input == null or members.size() < 2 or _cooldown_timer > 0.0:
		return
	if _input.is_swap_next_just_pressed():
		swap_by(1)
	elif _input.is_swap_prev_just_pressed():
		swap_by(-1)


## Hands control to the sister `step` places along the roster, wrapping around.
func swap_by(step: int) -> void:
	var from: Sister = get_active()
	_active_index = posmod(_active_index + step, members.size())
	var to: Sister = get_active()
	to.set_active(true)
	to.take_over_from(from)
	from.set_active(false)
	to.input = _input
	_cooldown_timer = swap_cooldown
	swapped.emit(from, to)
