extends Node3D

const WorldScript = preload("res://scripts/room_world.gd")
const WorkerScript = preload("res://scripts/worker.gd")
const HudScript = preload("res://scripts/hud.gd")
var world: Node3D
var worker: Node3D
var hud: CanvasLayer
var camera: Camera3D
var angle: int = 0
var camera_tween: Tween
var coins: int = 0
var pending: int = 0
var producing: bool = false
var automatic: bool = true
var production_time: float = 0.0
var status: String = "Bereit für den ersten Auftrag"
var settings := ConfigFile.new()

func _ready() -> void:
	settings.load("user://settings.cfg")
	automatic = settings.get_value("game", "automatic", true)
	world = WorldScript.new()
	add_child(world)
	worker = WorkerScript.new()
	add_child(worker)
	worker.position = world.to_world(Vector2i(3, 9))
	worker.arrived.connect(_on_arrived)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 21
	camera.current = true
	add_child(camera)
	set_camera_angle()
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-60, -30, 0)
	light.light_energy = 1.3
	add_child(light)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("101b2c")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("b5c8e2")
	environment.environment.ambient_light_energy = 0.65
	add_child(environment)
	hud = HudScript.new()
	hud.game = self
	add_child(hud)

func set_camera_angle() -> void:
	var radians := deg_to_rad(45.0 + angle * 90.0)
	camera.position = Vector3(sin(radians) * 18, 18, cos(radians) * 18)
	camera.look_at(Vector3.ZERO)

func rotate_camera(direction: int) -> void:
	if camera_tween and camera_tween.is_running():
		return
	var old_transform := camera.transform
	angle = posmod(angle + direction, 4)
	set_camera_angle()
	var new_transform := camera.transform
	camera.transform = old_transform
	camera_tween = create_tween()
	camera_tween.tween_property(camera, "transform", new_transform, 0.3).set_trans(Tween.TRANS_SINE)

func go_to_station() -> void:
	producing = false
	production_time = 0
	worker.follow(world.path_to(world.to_cell(worker.position), Vector2i(9, 3)))
	status = "Auf dem Weg zur Werkbank …"

func explore() -> void:
	producing = false
	var destination: Vector2i = world.walkable.pick_random()
	worker.follow(world.path_to(world.to_cell(worker.position), destination))
	status = "Erkundet die Räume …"

func _on_arrived() -> void:
	producing = world.to_cell(worker.position) == Vector2i(9, 3)
	status = "Produziert an der Werkbank" if producing else "Ziel erreicht"

func _process(delta: float) -> void:
	if producing and automatic:
		production_time += delta
		if production_time >= 3.0:
			production_time -= 3.0
			pending += 1

func collect() -> void:
	coins += pending
	pending = 0

func save_settings() -> void:
	settings.set_value("game", "automatic", automatic)
	settings.set_value("game", "speed", worker.speed)
	settings.save("user://settings.cfg")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			hud.open_menu()
		elif event.keycode == KEY_Q:
			rotate_camera(-1)
		elif event.keycode == KEY_E:
			rotate_camera(1)
	var pressed: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	pressed = pressed or (event is InputEventScreenTouch and event.pressed)
	if pressed:
		var screen: Vector2 = event.position
		var origin := camera.project_ray_origin(screen)
		var hit: Variant = Plane(Vector3.UP, 0).intersects_ray(origin, camera.project_ray_normal(screen))
		if hit != null:
			var cell: Vector2i = world.to_cell(hit)
			if cell == world.TARGET:
				go_to_station()
			elif world.grid.is_in_boundsv(cell) and not world.grid.is_point_solid(cell):
				producing = false
				worker.follow(world.path_to(world.to_cell(worker.position), cell))
				status = "Unterwegs …"
