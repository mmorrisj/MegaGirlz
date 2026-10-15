extends RefCounted
## Magic Cliffs: a horizontal scrolling section with parallax layers.

const LEVEL: String = "res://scenes/levels/magic_cliffs.tscn"


func test_sister_lands_at_spawn(ctx: TestContext) -> void:
	var level: Node = ctx.load_room(LEVEL)
	var gigi: Sister = level.get_node("Gigi")
	await ctx.physics_frames(40)
	ctx.check(gigi.is_on_floor(), "Gigi should land on the ground near the spawn point")
	ctx.check(gigi.global_position.y < 240.0, "Gigi should be standing in the stage, y=%.0f" % gigi.global_position.y)


func test_camera_scrolls_and_layers_move_at_different_speeds(ctx: TestContext) -> void:
	var level: Node = ctx.load_room(LEVEL)
	var gigi: Sister = level.get_node("Gigi")
	var camera: Camera2D = level.get_node("Camera2D")
	await ctx.physics_frames(40)
	var start_view: float = camera.get_screen_center_position().x
	var start_x: float = gigi.global_position.x
	ctx.press_key(KEY_D)
	await ctx.physics_frames(90)
	ctx.release_key(KEY_D)
	await ctx.physics_frames(2)
	ctx.check(gigi.global_position.x > start_x + 150.0, "Gigi should run well to the right, moved %.0f" % (gigi.global_position.x - start_x))
	# The camera can't scroll left of the stage, so it only starts moving once
	# Gigi passes the middle of the screen; from then on it keeps her centered.
	var view_x: float = camera.get_screen_center_position().x
	ctx.check(view_x > start_view, "The camera should scroll right with Gigi")
	ctx.check(absf(view_x - gigi.global_position.x) <= 1.0,
		"Gigi should stay centered once past mid-screen (view %.0f, Gigi %.0f)" % [view_x, gigi.global_position.x])
	ctx.check(is_equal_approx(view_x, roundf(view_x)), "The scroll position should be a whole pixel, got %.2f" % view_x)
	var previous: float = 0.0
	for layer_name in ["Sky", "Clouds", "Sea", "FarGrounds"]:
		var layer: Parallax2D = level.get_node("Background/" + layer_name)
		ctx.check(layer.scroll_scale.x > previous and layer.scroll_scale.x < 1.0,
			"%s should scroll slower than nearer layers and the level" % layer_name)
		previous = layer.scroll_scale.x


func test_camera_follows_swapped_sister(ctx: TestContext) -> void:
	var level: Node = ctx.load_room(LEVEL)
	var camera: Camera2D = level.get_node("Camera2D")
	await ctx.physics_frames(40)
	ctx.press_key(KEY_D)
	await ctx.physics_frames(60)
	await ctx.tap_key(KEY_E)
	await ctx.physics_frames(30)
	ctx.release_key(KEY_D)
	await ctx.physics_frames(2)
	var evie: Sister = level.get_node("Evie")
	ctx.check(evie.visible, "Evie should be on stage after the swap")
	ctx.check(absf(camera.global_position.x - evie.global_position.x) <= 1.0,
		"The camera should track Evie after the swap")


func test_falling_into_a_pit_respawns(ctx: TestContext) -> void:
	var level: Node = ctx.load_room(LEVEL)
	var gigi: Sister = level.get_node("Gigi")
	var spawn: Marker2D = level.get_node("SpawnPoint")
	await ctx.physics_frames(10)
	gigi.global_position = Vector2(300, 400)
	await ctx.physics_frames(2)
	ctx.check(gigi.global_position.distance_to(spawn.global_position) < 10.0,
		"Falling out of the stage should return Gigi to the spawn point")
