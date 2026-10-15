extends RefCounted
## Per-player input: each device drives only the player slot bound to it.


func test_keyboard_drives_only_player_one(ctx: TestContext) -> void:
	InputBindings.bind_joypad(1, 0)
	ctx.press_key(KEY_SPACE)
	await ctx.physics_frames(1)
	ctx.check(Input.is_action_pressed(&"p1_jump"), "Space should press p1_jump")
	ctx.check(not Input.is_action_pressed(&"p2_jump"), "Space should not press p2_jump")


func test_joypad_drives_only_its_player(ctx: TestContext) -> void:
	InputBindings.bind_joypad(1, 0)
	ctx.joy_button(0, JOY_BUTTON_A, true)
	await ctx.physics_frames(1)
	ctx.check(Input.is_action_pressed(&"p2_jump"), "Joypad 0 A should press p2_jump")
	ctx.check(not Input.is_action_pressed(&"p1_jump"), "Joypad 0 A should not press p1_jump")
	ctx.joy_button(0, JOY_BUTTON_A, false)
	ctx.joy_button(1, JOY_BUTTON_A, true)
	await ctx.physics_frames(1)
	ctx.check(not Input.is_action_pressed(&"p2_jump"), "Joypad 1 should not drive player 2")
	ctx.joy_button(1, JOY_BUTTON_A, false)


func test_joypad_stick_moves(ctx: TestContext) -> void:
	InputBindings.bind_joypad(1, 0)
	var input := PlayerInput.new(1)
	ctx.joy_axis(0, JOY_AXIS_LEFT_X, -0.8)
	await ctx.physics_frames(1)
	ctx.check(input.get_move_axis() < 0.0, "Stick left should give a negative move axis")
	ctx.joy_axis(0, JOY_AXIS_LEFT_X, 0.0)
	await ctx.physics_frames(1)
	ctx.check(is_zero_approx(input.get_move_axis()), "Centered stick should give zero")
