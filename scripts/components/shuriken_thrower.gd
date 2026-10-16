class_name ShurikenThrower
extends Node2D
## Throws shuriken from this point; place it at the throwing hand. Limits how
## many stars can be in flight at once, Mega Man style.

const SHURIKEN_SCENE: PackedScene = preload("res://scenes/projectiles/shuriken.tscn")

## The sister throwing; stars are added to her parent (the level), not to her,
## so they keep flying if she is swapped out.
@export var body: Node2D
@export var max_in_flight: int = 3
## How bright the star is tinted in the thrower's color; above 1.0 it glows.
@export var star_glow: float = 1.4

var _in_flight: int = 0


func can_throw() -> bool:
	return _in_flight < max_in_flight


func throw(direction: int) -> void:
	var star: Projectile = SHURIKEN_SCENE.instantiate()
	star.direction = direction
	var color: Color = (body as Sister).signature_color if body is Sister else Color.WHITE
	star.modulate = Color(color.r * star_glow, color.g * star_glow, color.b * star_glow)
	(star.get_node("Light") as PointLight2D).color = color
	body.get_parent().add_child(star)
	star.global_position = global_position
	_in_flight += 1
	star.tree_exited.connect(_on_star_tree_exited)


func get_in_flight() -> int:
	return _in_flight


func _on_star_tree_exited() -> void:
	_in_flight -= 1
