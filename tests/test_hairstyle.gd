extends RefCounted
## Per-sister hairstyle overlays (Evie's bangs) drawn over the shared sprite.


func test_only_evie_wears_bangs(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	await ctx.physics_frames(2)
	for sister_name in ["Gigi", "Evie", "Lucy"]:
		var overlay: SpriteOverlay = room.get_node("%s/SquashPivot/Visual/Hairstyle" % sister_name)
		var expected: bool = sister_name == "Evie"
		ctx.check(overlay.visible == expected,
			"%s's hairstyle overlay should be %s" % [sister_name, "shown" if expected else "hidden"])


func test_bangs_follow_the_body_animation(ctx: TestContext) -> void:
	var room: Node = ctx.load_room()
	var evie: Sister = room.get_node("Evie")
	var sprite: AnimatedSprite2D = evie.get_node("SquashPivot/Visual/Sprite")
	var overlay: SpriteOverlay = evie.get_node("SquashPivot/Visual/Hairstyle")
	await ctx.physics_frames(30)
	await ctx.tap_key(KEY_E)
	ctx.check(overlay.material == sprite.material, "The bangs should share Evie's palette material")
	ctx.press_key(KEY_D)
	var mismatches: int = 0
	for i in 40:
		await ctx.physics_frames(1)
		if overlay.animation != sprite.animation or overlay.frame != sprite.frame:
			mismatches += 1
		if i == 20:
			await ctx.tap_key(KEY_X)
	ctx.release_key(KEY_D)
	ctx.check(mismatches == 0, "The bangs should match the body's animation and frame every frame (%d mismatches)" % mismatches)


func test_overlay_frames_mirror_the_base_sprite(ctx: TestContext) -> void:
	var base: SpriteFrames = load("res://assets/characters/sister_base/sister_frames.tres")
	var bangs: SpriteFrames = load("res://assets/characters/evie/evie_bangs_frames.tres")
	for anim in base.get_animation_names():
		ctx.check(bangs.has_animation(anim), "Bangs should have the %s animation" % anim)
		if bangs.has_animation(anim):
			ctx.check(bangs.get_frame_count(anim) == base.get_frame_count(anim),
				"Bangs %s should have %d frames" % [anim, base.get_frame_count(anim)])
