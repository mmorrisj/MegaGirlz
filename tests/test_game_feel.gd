extends RefCounted
## Game-feel effects react to the sister's signals.


func test_jump_and_land_squash(ctx: TestContext) -> void:
	var gigi: Sister = ctx.load_room().get_node("Gigi")
	var pivot: Node2D = gigi.get_node("SquashPivot")
	await ctx.physics_frames(40)
	ctx.check(pivot.scale.is_equal_approx(Vector2.ONE), "Pivot should rest at scale 1")
	# An array, not a plain local: lambdas capture locals by value.
	var landed_scales: Array[Vector2] = []
	gigi.landed.connect(func(_speed: float) -> void: landed_scales.append(pivot.scale))
	ctx.press_key(KEY_SPACE)
	await ctx.physics_frames(2)
	ctx.check(pivot.scale.y > 1.05 and pivot.scale.x < 0.95, "Jump should stretch, got %s" % pivot.scale)
	for i in 80:
		await ctx.physics_frames(1)
		if not landed_scales.is_empty():
			break
	ctx.release_key(KEY_SPACE)
	ctx.check(landed_scales.size() == 1, "Jump should end in exactly one landing")
	if landed_scales.size() == 1:
		ctx.check(landed_scales[0].y < 0.95 and landed_scales[0].x > 1.05,
			"Landing should squash, got %s" % landed_scales[0])
	await ctx.physics_frames(30)
	ctx.check(pivot.scale.is_equal_approx(Vector2.ONE), "Squash should recover to scale 1")


func test_muzzle_flash(ctx: TestContext) -> void:
	var gigi: Sister = ctx.load_room().get_node("Gigi")
	var flash: Node2D = gigi.get_node("SquashPivot/Visual/MuzzleFlash")
	await ctx.physics_frames(30)
	ctx.check(not flash.visible, "Muzzle flash should be hidden at rest")
	await ctx.tap_key(KEY_J)
	ctx.check(flash.visible, "Muzzle flash should show when firing")
	await ctx.physics_frames(6)
	ctx.check(not flash.visible, "Muzzle flash should hide quickly")


func test_impact_sparks_and_shake(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var camera: ShakeCamera = room.get_node("Camera2D")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_J)
	var saw_spark: bool = false
	var max_offset: float = 0.0
	for i in 90:
		await ctx.physics_frames(1)
		saw_spark = saw_spark or _has_sparks(room)
		max_offset = maxf(max_offset, camera.offset.length())
	ctx.check(saw_spark, "A wall hit should spawn sparks")
	ctx.check(max_offset > 0.0 and max_offset <= 10.0, "Impact should shake 1-10 px, got %.1f" % max_offset)
	ctx.check(camera.offset == Vector2.ZERO, "Camera should settle after shaking")
	ctx.check(not _has_sparks(room), "Sparks should free themselves")


func test_shake_uses_whole_pixels(ctx: TestContext) -> void:
	var camera: ShakeCamera = ctx.load_room().get_node("Camera2D")
	camera.add_trauma(1.0)
	await ctx.physics_frames(1)
	ctx.check(camera.offset != Vector2.ZERO, "Full trauma should move the camera")
	ctx.check(camera.offset == camera.offset.round(), "Shake offset should be whole pixels")


func _has_sparks(node: Node) -> bool:
	return node.get_children().any(func(child: Node) -> bool: return child is CPUParticles2D)
