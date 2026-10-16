class_name Projectile
extends Area2D
## Straight-flying projectile (arm-cannon shot, shuriken). Disappears on
## hitting the world or leaving the screen.

const IMPACT_SPARK_SCENE: PackedScene = preload("res://scenes/vfx/impact_spark.tscn")

@export var speed: float = 360.0
## Safety net in case the shot never leaves the screen or hits anything.
@export var max_lifetime: float = 2.0
## Screen-shake trauma added when the shot hits something (0 to disable).
@export_range(0.0, 1.0) var impact_shake: float = 0.5

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
	_spawn_impact_spark()
	ShakeCamera.shake(get_tree(), impact_shake)
	queue_free()


func _spawn_impact_spark() -> void:
	var spark: CPUParticles2D = IMPACT_SPARK_SCENE.instantiate()
	# Sparks fly back toward the shooter.
	spark.scale.x = -direction
	# Sibling of the shot, positioned in world space, so it outlives the shot.
	spark.top_level = true
	get_parent().add_child(spark)
	spark.global_position = global_position
