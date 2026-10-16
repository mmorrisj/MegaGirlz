extends RefCounted
## Run, jump, and sword slash for one keyboard-controlled sister.


func test_lands_on_floor(ctx: TestContext) -> void:
	var gigi: Sister = _spawn_gigi(ctx)
	await ctx.physics_frames(30)
	ctx.check(gigi.is_on_floor(), "Gigi should land on the floor")


func test_runs_and_turns(ctx: TestContext) -> void:
	var gigi: Sister = _spawn_gigi(ctx)
	await ctx.physics_frames(30)
	var start_x: float = gigi.global_position.x
	await ctx.tap_key(KEY_D, 20)
	ctx.check(gigi.global_position.x > start_x + 30.0, "D should move Gigi right")
	await ctx.tap_key(KEY_LEFT, 5)
	await ctx.physics_frames(1)
	ctx.check(gigi.facing == -1, "Left arrow should turn Gigi left")


func test_jump_height_depends_on_hold(ctx: TestContext) -> void:
	var gigi: Sister = _spawn_gigi(ctx)
	await ctx.physics_frames(30)
	var full: float = await _jump_height(ctx, gigi, 40)
	ctx.check(full > 60.0 and full < 80.0, "Held jump should reach ~72 px, got %.1f" % full)
	await ctx.physics_frames(60)
	var tapped: float = await _jump_height(ctx, gigi, 3)
	ctx.check(tapped < full * 0.6, "Tapped jump should be much lower, got %.1f" % tapped)


func test_sword_slash_hits_only_mid_swing(ctx: TestContext) -> void:
	var gigi: Sister = _spawn_gigi(ctx)
	var hitbox: Area2D = gigi.get_node("SquashPivot/Visual/SwordHitbox")
	await ctx.physics_frames(30)
	ctx.check(not hitbox.monitoring, "The sword should be harmless at rest")
	await ctx.tap_key(KEY_J)
	ctx.check(gigi.is_attacking(), "J should start a slash")
	ctx.check(not hitbox.monitoring, "The wind-up should not hit yet")
	await ctx.physics_frames(8)
	var slash_time: float = gigi._attack_time
	await ctx.tap_key(KEY_J)
	ctx.check(gigi._attack_time > slash_time, "Pressing attack mid-slash should not restart it")
	var was_live: bool = false
	for i in 50:
		await ctx.physics_frames(1)
		was_live = was_live or hitbox.monitoring
	ctx.check(was_live, "The sword should hit during the swing")
	ctx.check(not gigi.is_attacking() and not hitbox.monitoring, "The slash should end and the sword go harmless")


func test_unassigned_sister_ignores_input(ctx: TestContext) -> void:
	var gigi: Sister = _spawn_gigi(ctx)
	await ctx.physics_frames(30)
	gigi.input = null
	var start_x: float = gigi.global_position.x
	await ctx.tap_key(KEY_D, 10)
	ctx.check(is_equal_approx(gigi.global_position.x, start_x), "Sister without a player should not move")


func _spawn_gigi(ctx: TestContext) -> Sister:
	return ctx.load_room().get_node("Gigi")


func _jump_height(ctx: TestContext, gigi: Sister, hold_frames: int) -> float:
	var start_y: float = gigi.global_position.y
	var peak: float = start_y
	ctx.press_key(KEY_SPACE)
	for i in 50:
		await ctx.physics_frames(1)
		peak = minf(peak, gigi.global_position.y)
		if i == hold_frames:
			ctx.release_key(KEY_SPACE)
	ctx.release_key(KEY_SPACE)
	return start_y - peak
