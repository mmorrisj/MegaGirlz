extends RefCounted
## Run, jump, and shoot for one keyboard-controlled sister.


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


func test_shot_limit_and_wall_hits(ctx: TestContext) -> void:
	var gigi: Sister = _spawn_gigi(ctx)
	await ctx.physics_frames(30)
	for i in 5:
		await ctx.tap_key(KEY_J)
		await ctx.physics_frames(2)
	ctx.check(gigi._live_shots == 3, "Only 3 shots may be alive, got %d" % gigi._live_shots)
	# Well under the 2 s lifetime: shots must be removed by hitting the room.
	await ctx.physics_frames(90)
	ctx.check(gigi._live_shots == 0, "Shots should be gone after hitting walls")


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
