extends Node2D
## Magic Cliffs stage: a horizontal scrolling section with parallax layers.
##
## Falling into a pit puts the active sister back at the spawn point. This is
## a stand-in until health and respawn rules exist.

@export var party: Party
@export var spawn_point: Marker2D
## Below this height the sister has fallen out of the stage.
@export var fall_limit_y: float = 320.0


func _physics_process(_delta: float) -> void:
	var active: Sister = party.get_active()
	if active.global_position.y > fall_limit_y:
		active.global_position = spawn_point.global_position
		active.velocity = Vector2.ZERO
