class_name PlayerInput
extends RefCounted
## Gameplay input for one player slot.
##
## A character holds a reference to one of these instead of reading Input
## directly. Swapping sisters hands the reference to another sister; the
## character scenes never change.

var player_index: int

var _move_left: StringName
var _move_right: StringName
var _jump: StringName
var _attack: StringName
var _swap_next: StringName
var _swap_prev: StringName


func _init(index: int) -> void:
	player_index = index
	_move_left = InputBindings.action_name(index, InputBindings.MOVE_LEFT)
	_move_right = InputBindings.action_name(index, InputBindings.MOVE_RIGHT)
	_jump = InputBindings.action_name(index, InputBindings.JUMP)
	_attack = InputBindings.action_name(index, InputBindings.ATTACK)
	_swap_next = InputBindings.action_name(index, InputBindings.SWAP_NEXT)
	_swap_prev = InputBindings.action_name(index, InputBindings.SWAP_PREV)


## -1.0 (left) to 1.0 (right).
func get_move_axis() -> float:
	return Input.get_axis(_move_left, _move_right)


func is_jump_held() -> bool:
	return Input.is_action_pressed(_jump)


func is_jump_just_pressed() -> bool:
	return Input.is_action_just_pressed(_jump)


func is_attack_just_pressed() -> bool:
	return Input.is_action_just_pressed(_attack)


func is_swap_next_just_pressed() -> bool:
	return Input.is_action_just_pressed(_swap_next)


func is_swap_prev_just_pressed() -> bool:
	return Input.is_action_just_pressed(_swap_prev)
