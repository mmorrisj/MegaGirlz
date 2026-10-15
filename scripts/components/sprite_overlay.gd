class_name SpriteOverlay
extends AnimatedSprite2D
## Extra art drawn over the shared sister sprite, such as one sister's own
## hairstyle. Its SpriteFrames must mirror the source's animations and frame
## counts; it shows whatever animation and frame the source shows, and shares
## the source's material so the sister's palette applies to it too.

@export var source: AnimatedSprite2D


func _ready() -> void:
	material = source.material
	source.animation_changed.connect(sync)
	source.frame_changed.connect(sync)
	sync()


func sync() -> void:
	if sprite_frames == null or not sprite_frames.has_animation(source.animation):
		return
	if animation != source.animation:
		animation = source.animation
	frame = source.frame
