extends Node2D
## Prototype room for tuning run, jump, and shoot. Gives player 1 control of Gigi.

@onready var _gigi: Sister = $Gigi


func _ready() -> void:
	_gigi.input = PlayerManager.get_input(0)
