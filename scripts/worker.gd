extends Node3D

signal arrived
@export var speed: float = 2.8
var path := PackedVector3Array()
var waypoint: int = 0

func _ready() -> void:
	var body := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.55, 1.05, 0.55)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("72ead6")
	mesh.material = material
	body.mesh = mesh
	body.position.y = 0.525
	add_child(body)

func follow(new_path: PackedVector3Array) -> void:
	path = new_path
	waypoint = 0

func _physics_process(delta: float) -> void:
	if waypoint >= path.size():
		return
	position = position.move_toward(path[waypoint], speed * delta)
	if position.distance_to(path[waypoint]) < 0.01:
		waypoint += 1
		if waypoint == path.size():
			arrived.emit()
