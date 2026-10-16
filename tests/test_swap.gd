extends RefCounted
## Single-player sister swapping through the Party node.


func test_starts_with_only_gigi_on_stage(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	await ctx.physics_frames(5)
	var party: Party = room.get_node("Party")
	ctx.check(party.get_active().name == "Gigi", "Gigi should start on stage")
	for sister_name in ["Evie", "Lucy"]:
		var sister: Sister = room.get_node(sister_name)
		ctx.check(not sister.visible, "%s should start hidden" % sister_name)
		ctx.check(sister.process_mode == Node.PROCESS_MODE_DISABLED, "%s should start paused" % sister_name)
		ctx.check(sister.get_node("CollisionShape2D").disabled, "%s should start without collision" % sister_name)


func test_swap_next_and_previous_wrap_around(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var party: Party = room.get_node("Party")
	await ctx.physics_frames(30)
	var order: Array[String] = []
	for i in 3:
		await ctx.tap_key(KEY_E)
		await ctx.physics_frames(15)  # past the swap cooldown
		order.append(party.get_active().name)
	ctx.check(order == ["Evie", "Lucy", "Gigi"], "E should cycle forward and wrap, got %s" % [order])
	await ctx.tap_key(KEY_Q)
	ctx.check(party.get_active().name == "Lucy", "Q from Gigi should wrap back to Lucy")


func test_swap_keeps_position_and_momentum(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var gigi: Sister = room.get_node("Gigi")
	var evie: Sister = room.get_node("Evie")
	await ctx.physics_frames(30)
	ctx.press_key(KEY_A)
	ctx.press_key(KEY_SPACE)
	await ctx.physics_frames(6)
	var gigi_position: Vector2 = gigi.global_position
	var gigi_velocity: Vector2 = gigi.velocity
	ctx.check(gigi_velocity.y < 0.0, "Gigi should be rising before the swap")
	var swaps: Array[String] = []
	room.get_node("Party").swapped.connect(
		func(from: Sister, to: Sister) -> void: swaps.append("%s>%s" % [from.name, to.name]))
	await ctx.tap_key(KEY_E)
	ctx.check(swaps == ["Gigi>Evie"], "Party should report the swap, got %s" % [swaps])
	ctx.check(evie.visible and not gigi.visible, "Evie should replace Gigi on stage")
	ctx.check(evie.global_position.distance_to(gigi_position) < 20.0, "Evie should appear where Gigi was")
	ctx.check(evie.facing == -1, "Evie should face the way Gigi faced")
	ctx.check(evie.velocity.y < 0.0, "Evie should keep rising mid-jump")
	await ctx.physics_frames(4)
	ctx.check(evie.global_position.x < gigi_position.x, "Evie should keep running left under player control")
	ctx.release_key(KEY_A)
	ctx.release_key(KEY_SPACE)


func test_swap_cooldown(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var party: Party = room.get_node("Party")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_E)
	await ctx.tap_key(KEY_E)
	ctx.check(party.get_active().name == "Evie", "A second press inside the cooldown should be ignored")


func test_swapping_mid_slash_ends_it(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var gigi: Sister = room.get_node("Gigi")
	var evie: Sister = room.get_node("Evie")
	var hitbox: Area2D = gigi.get_node("SquashPivot/Visual/SwordHitbox")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_J)
	await ctx.physics_frames(20)
	ctx.check(hitbox.monitoring, "Gigi's sword should be live mid-swing")
	await ctx.tap_key(KEY_E)
	ctx.check(not gigi.is_attacking() and not hitbox.monitoring, "Swapping out should end Gigi's slash")
	ctx.check(not evie.is_attacking(), "Evie should arrive ready, not mid-slash")


func test_each_sister_has_her_own_palette(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	await ctx.physics_frames(2)
	var colors: Array[Color] = []
	for sister_name in ["Gigi", "Evie", "Lucy"]:
		var sprite: AnimatedSprite2D = room.get_node("%s/SquashPivot/Visual/Sprite" % sister_name)
		var palette: ShaderMaterial = sprite.material
		colors.append(palette.get_shader_parameter(&"target_outfit"))
	ctx.check(colors[0] != colors[1] and colors[1] != colors[2] and colors[0] != colors[2],
		"Each sister should get a distinct main color, got %s" % [colors])


func test_gigi_has_her_own_hair_frames(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	await ctx.physics_frames(2)
	var gigi: AnimatedSprite2D = room.get_node("Gigi/SquashPivot/Visual/Sprite")
	var evie: AnimatedSprite2D = room.get_node("Evie/SquashPivot/Visual/Sprite")
	ctx.check(gigi.sprite_frames != evie.sprite_frames, "Gigi should use her own (braid-free) frames")
	var base: SpriteFrames = evie.sprite_frames
	var ok: bool = true
	for anim in base.get_animation_names():
		ok = ok and gigi.sprite_frames.has_animation(anim) \
			and gigi.sprite_frames.get_frame_count(anim) == base.get_frame_count(anim)
	ctx.check(ok, "Gigi's frames should mirror every base animation and frame")
