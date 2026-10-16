extends RefCounted
## Lucy's smash: attack after her double jump to plunge and hit the ground.


func _swap_to_lucy(ctx: TestContext, room: Node) -> Sister:
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_Q)
	await ctx.physics_frames(15)
	return room.get_node("Lucy")


## Jumps, then air-jumps, leaving her rising from the second jump.
func _double_jump(ctx: TestContext) -> void:
	await ctx.tap_key(KEY_SPACE, 15)
	await ctx.physics_frames(4)
	await ctx.tap_key(KEY_SPACE, 6)


func test_attack_after_double_jump_smashes_down(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var lucy: Sister = await _swap_to_lucy(ctx, room)
	var kit: DoubleJumpAbility = lucy.get_node("DoubleJump")
	var sprite: AnimatedSprite2D = lucy.get_node("SquashPivot/Visual/Sprite")
	await _double_jump(ctx)
	await ctx.tap_key(KEY_X)
	ctx.check(kit.is_smashing(), "Attack after the double jump should start a smash")
	ctx.check(not lucy.is_attacking(), "The smash should replace the air slash")
	ctx.check(sprite.animation == &"smash", "The smash pose should show, got %s" % sprite.animation)
	ctx.check(is_equal_approx(lucy.velocity.y, kit.smash_speed) and is_zero_approx(lucy.velocity.x),
		"She should plunge straight down at smash speed")


func test_attack_before_double_jump_is_the_air_slash(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var lucy: Sister = await _swap_to_lucy(ctx, room)
	var kit: DoubleJumpAbility = lucy.get_node("DoubleJump")
	ctx.press_key(KEY_SPACE)
	await ctx.physics_frames(6)
	await ctx.tap_key(KEY_X)
	ctx.release_key(KEY_SPACE)
	ctx.check(not kit.is_smashing(), "Without the double jump there should be no smash")
	ctx.check(lucy.is_attacking() and lucy.attack_kind == Sister.AttackKind.AIR, "It should be the normal air slash")


func test_smash_impact_shockwave_shake_and_hitbox(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var lucy: Sister = await _swap_to_lucy(ctx, room)
	var kit: DoubleJumpAbility = lucy.get_node("DoubleJump")
	var camera: ShakeCamera = room.get_node("Camera2D")
	await _double_jump(ctx)
	await ctx.tap_key(KEY_X)
	var sprite: AnimatedSprite2D = lucy.get_node("SquashPivot/Visual/Sprite")
	var landed: Array[bool] = [false]
	kit.smashed.connect(func() -> void: landed[0] = true)
	var held_pose: Array[bool] = [false]
	var hitbox_live: bool = false
	var wave_seen: bool = false
	var max_shake: float = 0.0
	for i in 60:
		await ctx.physics_frames(1)
		hitbox_live = hitbox_live or kit.get_smash_hitbox().monitoring
		if landed[0] and not held_pose[0] and lucy.is_on_floor():
			held_pose[0] = sprite.animation == &"smash"
		wave_seen = wave_seen or room.get_children().any(func(n: Node) -> bool: return n is Shockwave)
		max_shake = maxf(max_shake, camera.offset.length())
	ctx.check(landed[0], "The smash should hit the ground")
	ctx.check(not kit.is_smashing() and lucy.is_on_floor(), "She should end on the ground, smash over")
	ctx.check(wave_seen, "The impact should make a shockwave")
	ctx.check(held_pose[0], "She should hold the chop pose on landing")
	ctx.check(max_shake > 1.0, "The impact should shake the screen hard (max %.1f px)" % max_shake)
	ctx.check(hitbox_live, "The impact hitbox should be live briefly")
	ctx.check(not kit.get_smash_hitbox().monitoring, "The impact hitbox should switch off again")
	ctx.check(not room.get_children().any(func(n: Node) -> bool: return n is Shockwave), "The shockwave should free itself")


func test_swapping_out_mid_smash_cancels_it(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var lucy: Sister = await _swap_to_lucy(ctx, room)
	var kit: DoubleJumpAbility = lucy.get_node("DoubleJump")
	await _double_jump(ctx)
	await ctx.tap_key(KEY_X)
	await ctx.tap_key(KEY_E)
	ctx.check(not kit.is_smashing(), "Swapping Lucy out should cancel the smash")
	ctx.check(lucy.get_sprite().self_modulate == Color.WHITE, "Her smash glow should be cleared")
