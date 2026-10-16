extends RefCounted
## The sister's animation follows her movement and sword slashes.


func test_idle_run_jump_and_fall(ctx: TestContext) -> void:
	var gigi: Sister = ctx.load_room().get_node("Gigi")
	var sprite: AnimatedSprite2D = gigi.get_node("SquashPivot/Visual/Sprite")
	await ctx.physics_frames(30)
	ctx.check(sprite.animation == &"idle", "Standing still should idle, got %s" % sprite.animation)
	ctx.press_key(KEY_D)
	await ctx.physics_frames(5)
	ctx.check(sprite.animation == &"run", "Moving should run, got %s" % sprite.animation)
	ctx.release_key(KEY_D)
	await ctx.physics_frames(2)
	ctx.press_key(KEY_SPACE)
	await ctx.physics_frames(5)
	ctx.check(sprite.animation == &"jump", "Rising should show jump, got %s" % sprite.animation)
	await ctx.physics_frames(25)
	ctx.check(sprite.animation == &"fall", "Falling should show fall, got %s" % sprite.animation)


func test_slash_plays_to_the_end(ctx: TestContext) -> void:
	var gigi: Sister = ctx.load_room().get_node("Gigi")
	var sprite: AnimatedSprite2D = gigi.get_node("SquashPivot/Visual/Sprite")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_J)
	ctx.check(sprite.animation == &"attack", "Attacking should play the slash, got %s" % sprite.animation)
	ctx.press_key(KEY_D)
	await ctx.physics_frames(10)
	ctx.check(sprite.animation == &"attack", "Running mid-slash should not cut the slash short")
	ctx.release_key(KEY_D)
	await ctx.physics_frames(40)
	ctx.check(sprite.animation == &"idle", "After the slash she should idle again, got %s" % sprite.animation)
