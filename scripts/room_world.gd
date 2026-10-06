extends Node3D
## The same cells generate visuals and navigation, so walls cannot disagree with paths.

const SIZE := 13
const TARGET := Vector2i(10, 3)
var grid := AStarGrid2D.new()
var walkable: Array[Vector2i] = []

func _ready() -> void:
	grid.region = Rect2i(0, 0, SIZE, SIZE)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.update()
	for x in range(SIZE):
		for z in range(SIZE):
			var cell := Vector2i(x, z)
			var wall := x == 0 or z == 0 or x == 12 or z == 12
			wall = wall or (x == 6 and z != 3 and z != 9)
			wall = wall or (z == 6 and x != 3 and x != 9)
			grid.set_point_solid(cell, wall or cell == TARGET)
			if wall:
				box(Vector3(x - 6, 0.32, z - 6), Vector3(0.98, 0.64, 0.98), Color("34445f"))
			else:
				var colors := [Color("426a73"), Color("655f83"), Color("446880"), Color("7d6c59")]
				var room: int = int(x > 6) + 2 * int(z > 6)
				box(Vector3(x - 6, -0.12, z - 6), Vector3(0.97, 0.2, 0.97), colors[room])
				if cell != TARGET:
					walkable.append(cell)
	box(to_world(TARGET) + Vector3(0, 0.6, 0), Vector3(0.85, 1.2, 0.85), Color("ffba62"))

func to_world(cell: Vector2i) -> Vector3:
	return Vector3(cell.x - 6, 0, cell.y - 6)

func to_cell(point: Vector3) -> Vector2i:
	return Vector2i(roundi(point.x + 6), roundi(point.z + 6))

func path_to(start: Vector2i, destination: Vector2i) -> PackedVector3Array:
	var result := PackedVector3Array()
	if not grid.is_in_boundsv(start) or not grid.is_in_boundsv(destination):
		return result
	if grid.is_point_solid(destination):
		return result
	for cell in grid.get_id_path(start, destination):
		result.append(to_world(cell))
	return result

func box(at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	mesh.material = material
	node.mesh = mesh
	node.position = at
	add_child(node)
	return node
