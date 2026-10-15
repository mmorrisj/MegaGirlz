class_name CameraFollow
extends Node
## Scrolls a camera horizontally to keep the party's active sister centered,
## Mega Man style. Bound the scrolling section with the camera's limit_left
## and limit_right. Leave this node out for fixed-screen rooms.

@export var camera: Camera2D
@export var party: Party


func _ready() -> void:
	# Follow in the physics step, after the sisters move, so scrolling never
	# lags a frame behind them.
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	process_physics_priority = 10


func _physics_process(_delta: float) -> void:
	# Whole pixels only, so the pixel art never shimmers while scrolling.
	camera.global_position.x = roundf(party.get_active().global_position.x)
