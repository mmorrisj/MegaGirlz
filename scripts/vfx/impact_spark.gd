extends CPUParticles2D
## One-shot spark burst. Frees itself when the burst finishes.


func _ready() -> void:
	finished.connect(queue_free)
	emitting = true
