extends RefCounted
## Evie throws shuriken instead of slashing.


func _stars(room: Node) -> Array[Projectile]:
	var stars: Array[Projectile] = []
	for child in room.get_children():
		if child is Projectile:
			stars.append(child)
	return stars


func _swap_to_evie(ctx: TestContext, room: Node) -> Sister:
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_E)
	await ctx.physics_frames(15)
	return room.get_node("Evie")


func test_evie_throws_a_star_instead_of_slashing(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var evie: Sister = await _swap_to_evie(ctx, room)
	var sprite: AnimatedSprite2D = evie.get_node("SquashPivot/Visual/Sprite")
	var sword: Area2D = evie.get_node("SquashPivot/Visual/SwordHitbox")
	await ctx.tap_key(KEY_X)
	ctx.check(evie.attack_kind == Sister.AttackKind.THROW, "X should make Evie throw")
	ctx.check(sprite.animation == &"throw", "The throw animation should play, got %s" % sprite.animation)
	var stars := _stars(room)
	ctx.check(stars.size() == 1, "One star should be in flight, got %d" % stars.size())
	if stars.is_empty():
		return
	var star: Projectile = stars[0]
	var start_x: float = star.global_position.x
	var sword_live: bool = false
	for i in 10:
		await ctx.physics_frames(1)
		sword_live = sword_live or sword.monitoring
	ctx.check(is_instance_valid(star) and star.global_position.x > start_x + 30.0, "The star should fly forward")
	ctx.check(not sword_live, "Evie's sword hitbox should stay off")


func test_three_stars_at_most_and_they_break_on_walls(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var evie: Sister = await _swap_to_evie(ctx, room)
	var thrower: ShurikenThrower = evie.get_node("SquashPivot/Visual/ShurikenThrower")
	# Four quick throws (one per throw pose) land before the first star
	# reaches the crates about a second away; the fourth must be refused.
	for i in 4:
		await ctx.tap_key(KEY_X)
		await ctx.physics_frames(11)
	ctx.check(thrower.get_in_flight() == 3, "Only 3 stars may be in flight, got %d" % thrower.get_in_flight())
	# The crates on the right are well within the 2 s lifetime.
	await ctx.physics_frames(80)
	ctx.check(thrower.get_in_flight() == 0 and _stars(room).is_empty(), "Stars should break on the walls")


func test_evie_throws_in_the_air_too(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var evie: Sister = await _swap_to_evie(ctx, room)
	var arc: SlashArc = evie.get_node("SquashPivot/Visual/SlashArc")
	ctx.press_key(KEY_SPACE)
	await ctx.physics_frames(6)
	await ctx.tap_key(KEY_X)
	ctx.release_key(KEY_SPACE)
	ctx.check(evie.attack_kind == Sister.AttackKind.THROW, "X in the air should still throw")
	ctx.check(not arc.visible, "Evie should not do the overhead sword slash")
	ctx.check(_stars(room).size() == 1, "A star should be thrown from the air")


func test_gigi_and_lucy_keep_their_swords(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	ctx.check((room.get_node("Gigi") as Sister).weapon == Sister.Weapon.SWORD, "Gigi should use the sword")
	ctx.check((room.get_node("Lucy") as Sister).weapon == Sister.Weapon.SWORD, "Lucy should use the sword")
	ctx.check((room.get_node("Evie") as Sister).weapon == Sister.Weapon.SHURIKEN, "Evie should use shuriken")
	await ctx.physics_frames(1)
