extends RefCounted
## Signature abilities: Gigi's dash and Lucy's double jump.


func _count(room: Node, type_check: Callable) -> int:
	return room.get_children().filter(type_check).size()


func _is_afterimage(node: Node) -> bool:
	return node is Sprite2D and node.material is ShaderMaterial


func test_gigi_dashes_fast_and_leaves_afterimages(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var gigi: Sister = room.get_node("Gigi")
	var dash: DashAbility = gigi.get_node("Dash")
	var sprite: AnimatedSprite2D = gigi.get_node("SquashPivot/Visual/Sprite")
	await ctx.physics_frames(30)
	var start: Vector2 = gigi.global_position
	await ctx.tap_key(KEY_L)
	ctx.check(dash.is_dashing(), "L should start a dash")
	ctx.check(sprite.animation == &"dash", "The dash pose should show, got %s" % sprite.animation)
	await ctx.physics_frames(6)
	# 8 frames at the dash speed is ~44 px; running would cover ~19 px.
	ctx.check(gigi.global_position.x - start.x > 35.0, "The dash should be much faster than running (moved %.0f px)" % (gigi.global_position.x - start.x))
	ctx.check(_count(room, _is_afterimage) > 0, "The dash should leave afterimages")
	await ctx.physics_frames(10)
	ctx.check(not dash.is_dashing(), "The dash should end on its own")
	await ctx.physics_frames(20)
	ctx.check(_count(room, _is_afterimage) == 0, "Afterimages should fade away")


func test_gigi_air_dash_holds_height_once_per_jump(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var gigi: Sister = room.get_node("Gigi")
	var dash: DashAbility = gigi.get_node("Dash")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_SPACE, 12)
	await ctx.tap_key(KEY_L)
	ctx.check(dash.is_dashing(), "Gigi should be able to dash in the air")
	var height: float = gigi.global_position.y
	await ctx.physics_frames(4)
	ctx.check(absf(gigi.global_position.y - height) < 1.0, "Gravity should pause during the air dash")
	await ctx.physics_frames(25)
	await ctx.tap_key(KEY_L)
	ctx.check(gigi.is_on_floor() or not dash.is_dashing(), "Only one air dash per jump")


func test_jump_cancels_the_dash(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var gigi: Sister = room.get_node("Gigi")
	var dash: DashAbility = gigi.get_node("Dash")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_L)
	await ctx.tap_key(KEY_SPACE)
	ctx.check(not dash.is_dashing(), "Jumping should end the dash")
	ctx.check(gigi.velocity.y < 0.0, "Gigi should jump out of the dash")


func test_lucy_double_jumps_once_and_refills_on_landing(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var lucy: Sister = room.get_node("Lucy")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_Q)
	await ctx.physics_frames(15)
	var ground_y: float = lucy.global_position.y
	await ctx.tap_key(KEY_SPACE, 20)
	await ctx.physics_frames(4)
	ctx.check(lucy.velocity.y > 0.0, "Lucy should be falling after her first jump")
	var sparks_before: int = _count(room, func(n: Node) -> bool: return n is CPUParticles2D)
	ctx.press_key(KEY_SPACE)
	await ctx.physics_frames(2)
	ctx.check(lucy.velocity.y < 0.0, "A second jump in mid-air should launch Lucy upward")
	ctx.check(_count(room, func(n: Node) -> bool: return n is CPUParticles2D) > sparks_before, "The air jump should make a puff")
	var peak: float = lucy.global_position.y
	for i in 30:
		await ctx.physics_frames(1)
		peak = minf(peak, lucy.global_position.y)
	ctx.release_key(KEY_SPACE)
	ctx.check(ground_y - peak > 90.0, "Double jumping should go higher than one jump (rose %.0f px)" % (ground_y - peak))
	await ctx.tap_key(KEY_SPACE)
	ctx.check(lucy.velocity.y > 0.0, "A third jump in mid-air should do nothing")
	for i in 90:
		await ctx.physics_frames(1)
		if lucy.is_on_floor():
			break
	await ctx.physics_frames(2)
	await ctx.tap_key(KEY_SPACE, 10)
	await ctx.physics_frames(12)
	await ctx.tap_key(KEY_SPACE)
	ctx.check(lucy.velocity.y < 0.0, "The air jump should refill after landing")


func test_evie_has_no_double_jump(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var evie: Sister = room.get_node("Evie")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_E)
	await ctx.physics_frames(15)
	await ctx.tap_key(KEY_SPACE, 20)
	await ctx.physics_frames(4)
	await ctx.tap_key(KEY_SPACE)
	ctx.check(evie.velocity.y > 0.0, "Evie should not double jump")


func test_swapping_out_mid_dash_ends_it(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var gigi: Sister = room.get_node("Gigi")
	var dash: DashAbility = gigi.get_node("Dash")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_L)
	await ctx.tap_key(KEY_E)
	ctx.check(not dash.is_dashing(), "Swapping Gigi out should end her dash")
