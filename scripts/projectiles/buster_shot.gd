class_name BusterShot
extends Area2D
## Basic arm-cannon shot. Flies straight and disappears on hitting the world
## or leaving the screen.

@export var speed: float = 360.0
## Safety net in case the shot never leaves the screen or hits anything.
@export var max_lifetime: float = 2.0

## 1 = right, -1 = left. Set before adding to the tree.
var direction: int = 1

var _age: float = 0.0

@onready var _screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_screen_notifier.screen_exited.connect(queue_free)


func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	_age += delta
	if _age >= max_lifetime:
		queue_free()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
