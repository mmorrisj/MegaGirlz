class_name SwapBeam
extends Node2D
## Teleport-beam flash when a sister swaps in: a bright column in her color
## narrows away while her sprite flashes white.

@export var sprite: CanvasItem
@export var beam: ColorRect
@export var duration: float = 0.18
## Above 1.0 so the beam glows once HDR glow is enabled.
@export var brightness: float = 2.5

var _tween: Tween


func _ready() -> void:
	visible = false


func set_color(color: Color) -> void:
	beam.color = Color(color.r * brightness, color.g * brightness, color.b * brightness)


func play() -> void:
	if _tween:
		_tween.kill()
	visible = true
	scale = Vector2.ONE
	sprite.self_modulate = Color(3.0, 3.0, 3.0)
	_tween = create_tween().set_parallel()
	_tween.tween_property(self, "scale:x", 0.0, duration).set_ease(Tween.EASE_IN)
	_tween.tween_property(sprite, "self_modulate", Color.WHITE, duration)
	_tween.chain().tween_callback(hide)
