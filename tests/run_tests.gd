extends SceneTree
## Headless test runner. From the project folder:
##   godot --headless --path . -s res://tests/run_tests.gd
##
## Runs every test_* method in every tests/test_*.gd file. Each test gets a
## TestContext and should await its helpers. Exit code 0 means all passed.

const TestContextScript: GDScript = preload("res://tests/support/test_context.gd")
const TEST_DIR: String = "res://tests/"


func _initialize() -> void:
	_run_all.call_deferred()


func _run_all() -> void:
	var ctx: TestContext = TestContextScript.new(self)
	var test_count: int = 0
	var failed_tests: int = 0
	for file_name: String in DirAccess.get_files_at(TEST_DIR):
		if not (file_name.begins_with("test_") and file_name.ends_with(".gd")):
			continue
		var script: GDScript = load(TEST_DIR + file_name)
		var suite: Object = script.new()
		for method: Dictionary in script.get_script_method_list():
			var method_name: String = method.name
			if not method_name.begins_with("test_"):
				continue
			var test_name: String = "%s.%s" % [file_name.get_basename(), method_name]
			var failures_before: int = ctx.failures
			ctx.current_test = test_name
			await Callable(suite, method_name).call(ctx)
			await ctx.reset()
			test_count += 1
			var passed: bool = ctx.failures == failures_before
			if not passed:
				failed_tests += 1
			print("%s %s" % ["ok  " if passed else "FAIL", test_name])
	print("\n%d tests, %d failed (%d checks, %d failed)" % [
		test_count, failed_tests, ctx.checks, ctx.failures])
	quit(1 if failed_tests > 0 else 0)
