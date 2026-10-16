extends RefCounted
## Evie's slide: a fast, low ground slide that hits what's in front of her.


func _swap_to_evie(ctx: TestContext, room: Node) -> Sister:
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_E)
	await ctx.physics_frames(15)
	return room.get_node("Evie")


func test_slide_is_fast_low_and_hits(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var evie: Sister = await _swap_to_evie(ctx, room)
	var slide: SlideAbility = evie.get_node("Slide")
	var sprite: AnimatedSprite2D = evie.get_node("SquashPivot/Visual/Sprite")
	var collision: CollisionShape2D = evie.get_collision_shape()
	var start_x: float = evie.global_position.x
	await ctx.tap_key(KEY_L)
	ctx.check(slide.is_sliding(), "L should make Evie slide")
	ctx.check(sprite.animation == &"slide", "The slide pose should show, got %s" % sprite.animation)
	ctx.check(collision.scale.y < 0.75, "Her collision should shrink while sliding")
	ctx.check(slide.get_slide_hitbox().monitoring, "The slide should hit what's in front of her")
	await ctx.physics_frames(8)
	# 10 frames at slide speed is ~43 px; running would cover ~23 px.
	ctx.check(evie.global_position.x - start_x > 35.0, "The slide should be faster than running (moved %.0f px)" % (evie.global_position.x - start_x))
	ctx.check(evie.is_on_floor(), "She should stay on the ground while sliding")
	await ctx.physics_frames(20)
	ctx.check(not slide.is_sliding(), "The slide should end on its own")
	ctx.check(is_equal_approx(collision.scale.y, 1.0) and is_zero_approx(collision.position.y), "Her collision should be restored")
	ctx.check(not slide.get_slide_hitbox().monitoring, "The slide hitbox should switch off")
	ctx.check(is_zero_approx(sprite.offset.y), "The sprite offset should be restored")


func test_no_slide_in_the_air(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var evie: Sister = await _swap_to_evie(ctx, room)
	var slide: SlideAbility = evie.get_node("Slide")
	ctx.press_key(KEY_SPACE)
	await ctx.physics_frames(6)
	await ctx.tap_key(KEY_L)
	ctx.release_key(KEY_SPACE)
	ctx.check(not slide.is_sliding(), "Evie should not slide in the air")


func test_jump_cancels_the_slide(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var evie: Sister = await _swap_to_evie(ctx, room)
	var slide: SlideAbility = evie.get_node("Slide")
	await ctx.tap_key(KEY_L)
	await ctx.tap_key(KEY_SPACE)
	ctx.check(not slide.is_sliding(), "Jumping should end the slide")
	ctx.check(evie.velocity.y < 0.0, "Evie should jump out of the slide")
	ctx.check(is_equal_approx(evie.get_collision_shape().scale.y, 1.0), "Her collision should be full height again")


func test_slide_under_a_low_ceiling_waits_for_headroom(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var evie: Sister = await _swap_to_evie(ctx, room)
	var slide: SlideAbility = evie.get_node("Slide")
	# A low ceiling just above her slide height, a little ahead of her.
	var ceiling := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(120, 10)
	shape.shape = rect
	ceiling.add_child(shape)
	room.add_child(ceiling)
	var feet_y: float = evie.global_position.y + 20.0
	ceiling.global_position = Vector2(evie.global_position.x + 70.0, feet_y - 28.0)
	await ctx.physics_frames(2)
	await ctx.tap_key(KEY_L)
	var stood_under: bool = false
	for i in 60:
		await ctx.physics_frames(1)
		var under: bool = absf(evie.global_position.x - ceiling.global_position.x) < 55.0
		if under and not slide.is_sliding():
			stood_under = true
	ctx.check(not stood_under, "She should never stand up under the low ceiling")
	ctx.check(evie.global_position.x > ceiling.global_position.x + 60.0, "She should slide out the other side")
	ctx.check(not slide.is_sliding(), "The slide should end once there's headroom")


func test_swapping_out_mid_slide_restores_her(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var evie: Sister = await _swap_to_evie(ctx, room)
	var slide: SlideAbility = evie.get_node("Slide")
	await ctx.tap_key(KEY_L)
	await ctx.tap_key(KEY_E)
	ctx.check(not slide.is_sliding(), "Swapping out should end the slide")
	ctx.check(is_equal_approx(evie.get_collision_shape().scale.y, 1.0), "Her collision should be full height again")
