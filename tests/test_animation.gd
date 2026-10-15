extends RefCounted
## The sister's animation follows her movement and shooting.


func test_idle_run_and_jump(ctx: TestContext) -> void:
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
	ctx.check(sprite.animation == &"jump", "Airborne should show jump, got %s" % sprite.animation)


func test_shoot_pose_standing_and_running(ctx: TestContext) -> void:
	var gigi: Sister = ctx.load_room().get_node("Gigi")
	var sprite: AnimatedSprite2D = gigi.get_node("SquashPivot/Visual/Sprite")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_J)
	ctx.check(sprite.animation == &"shoot", "Firing while standing should show shoot, got %s" % sprite.animation)
	await ctx.physics_frames(25)
	ctx.check(sprite.animation == &"idle", "Shoot pose should end after ~0.25 s, got %s" % sprite.animation)
	ctx.press_key(KEY_D)
	await ctx.physics_frames(8)
	var stride_frame: int = sprite.frame
	await ctx.tap_key(KEY_J)
	ctx.check(sprite.animation == &"run_shoot", "Firing while running should show run_shoot, got %s" % sprite.animation)
	ctx.check(sprite.frame == stride_frame or sprite.frame == (stride_frame + 1) % 4,
		"Run and run_shoot should share the stride (was %d, now %d)" % [stride_frame, sprite.frame])
