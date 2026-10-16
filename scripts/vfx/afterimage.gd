class_name Afterimage
extends Sprite2D
## A fading silhouette of a sister's current frame in her color, left behind
## by fast moves (Gigi's dash, Lucy's smash).

const SILHOUETTE_SHADER: Shader = preload("res://assets/vfx/silhouette.gdshader")

static var _material: ShaderMaterial


## Leaves an afterimage where `body` is now. brightness above 1.0 glows.
static func spawn(body: Sister, brightness: float, fade_time: float) -> void:
	if _material == null:
		_material = ShaderMaterial.new()
		_material.shader = SILHOUETTE_SHADER
	var sprite: AnimatedSprite2D = body.get_sprite()
	var ghost := Afterimage.new()
	ghost.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	ghost.material = _material
	var color: Color = body.signature_color
	ghost.modulate = Color(color.r * brightness, color.g * brightness, color.b * brightness, 0.7)
	# Added to the level so the trail stays behind, just before the sister in
	# the tree so it draws behind her but in front of the level art.
	var level: Node = body.get_parent()
	level.add_child(ghost)
	level.move_child(ghost, body.get_index())
	ghost.global_transform = sprite.global_transform
	var tween: Tween = ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, fade_time)
	tween.tween_callback(ghost.queue_free)
