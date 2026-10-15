class_name MuzzleFlash
extends Node2D
## Brief bright flash at a gun barrel. Call flash() each time a shot fires.

@export var duration: float = 0.05

var _tween: Tween


func _ready() -> void:
	visible = false


func flash() -> void:
	if _tween:
		_tween.kill()
	visible = true
	_tween = create_tween()
	_tween.tween_interval(duration)
	_tween.tween_callback(hide)
