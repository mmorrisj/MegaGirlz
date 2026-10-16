extends RefCounted
## Overhead slash: attacking in the air instead of on the ground.


func test_attack_in_the_air_is_an_overhead_slash(ctx: TestContext) -> void:
	var gigi: Sister = ctx.load_room().get_node("Gigi")
	var sprite: AnimatedSprite2D = gigi.get_node("SquashPivot/Visual/Sprite")
	var air_hitbox: Area2D = gigi.get_node("SquashPivot/Visual/AirSlashHitbox")
	var ground_hitbox: Area2D = gigi.get_node("SquashPivot/Visual/SwordHitbox")
	var arc: SlashArc = gigi.get_node("SquashPivot/Visual/SlashArc")
	await ctx.physics_frames(30)
	ctx.press_key(KEY_SPACE)
	await ctx.physics_frames(6)
	await ctx.tap_key(KEY_X)
	ctx.check(gigi.is_attacking() and gigi.attack_kind == Sister.AttackKind.AIR, "X in the air should start an air slash")
	ctx.check(sprite.animation == &"air_slash", "The air slash animation should play, got %s" % sprite.animation)
	ctx.check(arc.visible, "The slash arc should appear")
	var air_live: bool = false
	var ground_live: bool = false
	for i in 25:
		await ctx.physics_frames(1)
		air_live = air_live or air_hitbox.monitoring
		ground_live = ground_live or ground_hitbox.monitoring
	ctx.release_key(KEY_SPACE)
	ctx.check(air_live, "The overhead hitbox should hit during the sweep")
	ctx.check(not ground_live, "The ground slash hitbox should stay off")
	ctx.check(not gigi.is_attacking() and not air_hitbox.monitoring, "The air slash should end on its own")


func test_ground_attack_is_still_the_ground_slash(ctx: TestContext) -> void:
	var gigi: Sister = ctx.load_room().get_node("Gigi")
	var sprite: AnimatedSprite2D = gigi.get_node("SquashPivot/Visual/Sprite")
	var air_hitbox: Area2D = gigi.get_node("SquashPivot/Visual/AirSlashHitbox")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_X)
	ctx.check(gigi.attack_kind == Sister.AttackKind.GROUND, "X on the ground should be the ground slash")
	ctx.check(sprite.animation == &"attack", "The ground slash animation should play, got %s" % sprite.animation)
	var air_live: bool = false
	for i in 40:
		await ctx.physics_frames(1)
		air_live = air_live or air_hitbox.monitoring
	ctx.check(not air_live, "The overhead hitbox should stay off on the ground")


func test_landing_cuts_the_air_slash_short(ctx: TestContext) -> void:
	var gigi: Sister = ctx.load_room().get_node("Gigi")
	var arc: SlashArc = gigi.get_node("SquashPivot/Visual/SlashArc")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_SPACE, 3)
	# A tapped jump is short: wait until she is falling fast, so she lands
	# before the slash would finish on its own.
	for i in 30:
		await ctx.physics_frames(1)
		if gigi.velocity.y > 150.0:
			break
	await ctx.tap_key(KEY_X)
	ctx.check(gigi.is_attacking() and gigi.attack_kind == Sister.AttackKind.AIR, "Should start an air slash just before landing")
	for i in 15:
		await ctx.physics_frames(1)
		if gigi.is_on_floor():
			break
	await ctx.physics_frames(2)
	ctx.check(gigi.is_on_floor(), "She should have landed")
	ctx.check(not gigi.is_attacking(), "Landing should end the air slash")
	ctx.check(not arc.visible, "Landing should clear the slash arc")
