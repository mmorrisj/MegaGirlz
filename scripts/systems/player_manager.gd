extends Node
## Autoload that owns player slots: which input device drives which player.
##
## For now only player 1 exists, on the keyboard. Controllers, extra players,
## and drop-in/drop-out arrive in roadmap step 3.

const MAX_PLAYERS: int = 3

var _inputs: Array[PlayerInput] = []


func _ready() -> void:
	InputBindings.bind_keyboard(0)
	_inputs.append(PlayerInput.new(0))


## Returns the input for a player slot, or null if that slot is empty.
func get_input(player_index: int) -> PlayerInput:
	if player_index < 0 or player_index >= _inputs.size():
		return null
	return _inputs[player_index]
