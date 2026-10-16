class_name InputBindings
## Builds per-player InputMap actions such as "p1_jump" or "p2_move_left".
##
## Godot's default actions (ui_left, ...) accept every device at once, so two
## controllers would drive the same character. Each player slot instead gets
## its own actions, bound either to the keyboard or to one joypad device id.

const MOVE_LEFT: StringName = &"move_left"
const MOVE_RIGHT: StringName = &"move_right"
const JUMP: StringName = &"jump"
const ATTACK: StringName = &"attack"
const SWAP_NEXT: StringName = &"swap_next"
const SWAP_PREV: StringName = &"swap_prev"
## The active sister's signature ability (e.g. Gigi's dash).
const ABILITY: StringName = &"ability"
const ACTIONS: Array[StringName] = [MOVE_LEFT, MOVE_RIGHT, JUMP, ATTACK, SWAP_NEXT, SWAP_PREV, ABILITY]

## Same value as InputMap's internal ALL_DEVICES: the event matches any device.
const ALL_DEVICES: int = -1
const DEADZONE: float = 0.5


static func action_name(player_index: int, action: StringName) -> StringName:
	return StringName("p%d_%s" % [player_index + 1, action])


## Binds a player slot to the keyboard, replacing any previous bindings.
static func bind_keyboard(player_index: int) -> void:
	_reset_actions(player_index)
	_add_key(player_index, MOVE_LEFT, KEY_A)
	_add_key(player_index, MOVE_LEFT, KEY_LEFT)
	_add_key(player_index, MOVE_RIGHT, KEY_D)
	_add_key(player_index, MOVE_RIGHT, KEY_RIGHT)
	_add_key(player_index, JUMP, KEY_SPACE)
	_add_key(player_index, JUMP, KEY_K)
	_add_key(player_index, JUMP, KEY_Z)
	_add_key(player_index, ATTACK, KEY_J)
	_add_key(player_index, ATTACK, KEY_X)
	_add_key(player_index, SWAP_NEXT, KEY_E)
	_add_key(player_index, SWAP_NEXT, KEY_O)
	_add_key(player_index, SWAP_PREV, KEY_Q)
	_add_key(player_index, SWAP_PREV, KEY_U)
	_add_key(player_index, ABILITY, KEY_SHIFT)
	_add_key(player_index, ABILITY, KEY_L)


## Binds a player slot to one joypad, replacing any previous bindings.
static func bind_joypad(player_index: int, device: int) -> void:
	_reset_actions(player_index)
	_add_joy_axis(player_index, MOVE_LEFT, device, JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis(player_index, MOVE_RIGHT, device, JOY_AXIS_LEFT_X, 1.0)
	_add_joy_button(player_index, MOVE_LEFT, device, JOY_BUTTON_DPAD_LEFT)
	_add_joy_button(player_index, MOVE_RIGHT, device, JOY_BUTTON_DPAD_RIGHT)
	_add_joy_button(player_index, JUMP, device, JOY_BUTTON_A)
	_add_joy_button(player_index, ATTACK, device, JOY_BUTTON_X)
	_add_joy_button(player_index, SWAP_NEXT, device, JOY_BUTTON_RIGHT_SHOULDER)
	_add_joy_button(player_index, SWAP_PREV, device, JOY_BUTTON_LEFT_SHOULDER)
	_add_joy_button(player_index, ABILITY, device, JOY_BUTTON_B)


## Removes a player slot's actions entirely (e.g. on drop-out).
static func clear(player_index: int) -> void:
	for action: StringName in ACTIONS:
		var full_name: StringName = action_name(player_index, action)
		if InputMap.has_action(full_name):
			InputMap.erase_action(full_name)


static func _reset_actions(player_index: int) -> void:
	for action: StringName in ACTIONS:
		var full_name: StringName = action_name(player_index, action)
		if InputMap.has_action(full_name):
			InputMap.action_erase_events(full_name)
		else:
			InputMap.add_action(full_name, DEADZONE)


static func _add_key(player_index: int, action: StringName, key: Key) -> void:
	var event := InputEventKey.new()
	# Physical keycode keeps WASD in the same place on AZERTY/QWERTZ layouts.
	event.physical_keycode = key
	event.device = ALL_DEVICES
	InputMap.action_add_event(action_name(player_index, action), event)


static func _add_joy_button(
	player_index: int, action: StringName, device: int, button: JoyButton
) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.device = device
	InputMap.action_add_event(action_name(player_index, action), event)


static func _add_joy_axis(
	player_index: int, action: StringName, device: int, axis: JoyAxis, direction: float
) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = direction
	event.device = device
	InputMap.action_add_event(action_name(player_index, action), event)
