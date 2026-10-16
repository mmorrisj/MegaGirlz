extends CPUParticles2D
## One-shot spark burst. Frees itself when the burst finishes.


func _ready() -> void:
	finished.connect(queue_free)
	# Start at the end of the frame: spawners set the position right after
	# adding the node, and a burst started now would all be emitted at the
	# origin, off-screen.
	set_deferred("emitting", true)
