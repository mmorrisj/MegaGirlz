class_name TestContext
extends RefCounted
## Helpers for headless tests: checks, loading rooms, and faking input.
##
## Always wait with physics_frames(), not process frames: headless Godot runs
## process frames uncapped, so they say nothing about game time.

var tree: SceneTree
var current_test: String = ""
var checks: int = 0
var failures: int = 0

var _room: Node = null
var _held_keys: Array[Key] = []


func _init(scene_tree: SceneTree) -> void:
	tree = scene_tree


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("     %s: %s" % [current_test, message])


func load_room(path: String = "res://scenes/levels/test_room.tscn") -> Node:
	_room = load(path).instantiate()
	tree.root.add_child(_room)
	return _room


func physics_frames(count: int) -> void:
	for i in count:
		await tree.physics_frame


func press_key(key: Key) -> void:
	_send_key(key, true)
	_held_keys.append(key)


func release_key(key: Key) -> void:
	_send_key(key, false)
	_held_keys.erase(key)


## Presses a key, holds it for hold_frames physics frames, then releases it.
func tap_key(key: Key, hold_frames: int = 2) -> void:
	press_key(key)
	await physics_frames(hold_frames)
	release_key(key)


func joy_button(device: int, button: JoyButton, pressed: bool) -> void:
	var event := InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = pressed
	Input.parse_input_event(event)


func joy_axis(device: int, axis: JoyAxis, value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.device = device
	event.axis = axis
	event.axis_value = value
	Input.parse_input_event(event)


## Called by the runner after each test: releases input, frees the room,
## and removes any extra player bindings the test created.
func reset() -> void:
	for key: Key in _held_keys.duplicate():
		release_key(key)
	for player_index: int in range(1, 3):
		InputBindings.clear(player_index)
	if is_instance_valid(_room):
		_room.queue_free()
	_room = null
	await physics_frames(2)


func _send_key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)
