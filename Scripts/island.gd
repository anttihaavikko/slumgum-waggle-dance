class_name Island extends Node2D

@export var shapes: Array[Polygon2D]
@export var patch_prefab: PackedScene

@export var collider: CollisionPolygon2D
@export var poly: Polygon2D
@export var line: Line2D
@export var bg: Polygon2D
@export var flower_prefab: PackedScene
@export var ray: RayCast2D
@export var rock_prefab: PackedScene
@export var tree_prefab: PackedScene
@export var trees: Node2D

var gap := 5000
var pieces := 3

func _ready() -> void:
	generate()

func generate():
	var shape = get_shape(0)
	shape = append(shape, Vector2(0, 4000))
	for i in pieces:
		shape = append(shape, Vector2(-gap * (i + 1), 0))
		shape = append(shape, Vector2(gap * (i + 1), 0))
		shape = append(shape, Vector2(-gap * (i + 1), gap))
		shape = append(shape, Vector2(gap * (i + 1), gap))

	var left = 0
	var right = 0
	for p in shape:
		left = min(left, p.x)
		right = max(right, p.x)

	if left > -gap * pieces or right < gap * pieces:
		print("failed, retry!")
		generate()
		return

	collider.polygon = shape
	poly.polygon = shape
	line.points = shape
	bg.polygon = Geometry2D.offset_polygon(offset_points(shape.duplicate()), 100)[0]

	await get_tree().process_frame

	spawn_flower(-3500)
	spawn_flower(-2800)
	spawn_flower(2000)

	var spots := range(poly.polygon.size())
	spots.shuffle()

	for i in 50:
		var rock = rock_prefab.instantiate() as Node2D
		var p = poly.polygon[spots[i]]
		rock.global_position = p
		add_child(rock)

	for i in 75:
		var grass = patch_prefab.instantiate() as Node2D
		grass.rotate(PI * 2 * randf())
		var p = poly.polygon[spots[i + 50]]
		grass.global_position = p
		poly.add_child(grass)

	var tree_spots = range(bg.polygon.size())
	tree_spots.shuffle()

	for i in 200:
		var p = bg.polygon[tree_spots[i]]
		if not Geometry2D.is_point_in_polygon(p + Vector2.DOWN * 50, bg.polygon): continue
		var tree = tree_prefab.instantiate() as Node2D
		tree.scale *= randf_range(0.8, 1.2)
		trees.add_child(tree)
		tree.global_position = bg.to_global(p) + Vector2.UP * randf_range(400, 750)
		# tree.global_position.x *= -1

func shift(shape: PackedVector2Array, dir: Vector2) -> PackedVector2Array:
	for p in range(shape.size()):
		shape[p] += dir
	return shape

func spawn_flower(pos: float):
	ray.global_position = Vector2(global_position.x + pos, -5000)
	ray.force_raycast_update()
	if ray.is_colliding():
		var flower = flower_prefab.instantiate() as Flower
		add_child(flower)
		flower.global_position = ray.get_collision_point()

func offset_points(shape: PackedVector2Array, distance: float = 200) -> PackedVector2Array:
	for p in range(shape.size()):
		shape[p] += Vector2(randf_range(-distance, distance), randf_range(-distance, distance))
	return shape

func append(shape: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	return Geometry2D.merge_polygons(shape, get_shape(0, offset, true))[0]

func get_shape(index: int, offset: Vector2 = Vector2.ZERO, rotates: bool = false) -> PackedVector2Array:
	var shape = shapes[index].polygon.duplicate()
	var angle_rad = randf_range(-PI * 2, PI * 2)
	for p in range(shape.size()):
		shape[p] += offset
		if rotates:
			var pp = shape[p] - offset
			shape[p] = offset + pp.rotated(angle_rad)
	return shape
