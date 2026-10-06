extends SceneTree

var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)

func run() -> void:
	var game: Node3D = load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var path: PackedVector3Array = game.world.path_to(Vector2i(3, 9), Vector2i(9, 3))
	check(not path.is_empty(), "Path must connect opposite rooms")
	for point in path:
		check(not game.world.grid.is_point_solid(game.world.to_cell(point)), "Path crossed a wall")
	check(game.world.path_to(Vector2i(3, 9), game.world.TARGET).is_empty(), "Station must be blocked")
	game.go_to_station()
	for frame in range(600):
		game.worker._physics_process(1.0 / 60.0)
	check(game.producing, "Worker must arrive at station")
	game.automatic = true
	game._process(3.0)
	check(game.pending == 1, "Production must create one reward")
	game.collect()
	check(game.coins == 1 and game.pending == 0, "Collection must transfer rewards")
	game.hud.open_menu()
	var elapsed: float = game.production_time
	var position_before: Vector3 = game.worker.position
	await create_timer(0.15).timeout
	check(paused and game.production_time == elapsed and game.worker.position == position_before, "Menu must pause simulation")
	game.hud.close_menu()
	check(not paused, "Resume must unpause world")
	for index in range(4):
		game.rotate_camera(1)
		await create_timer(0.35).timeout
	check(game.angle == 0, "Four rotations must restore orientation")
	game.queue_free()
	await process_frame
	print("Smoke checks: ", "PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
