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
@export var huts: Array[PackedScene]
@export var explosion: Polygon2D
@export var wall: Polygon2D
@export var wall_line: Line2D
@export var dungeons: Array[Polygon2D]

var gap := 5000
var pieces := 3

func _ready() -> void:
	show()
	generate()
	Main.singleton.islands.append(self)
	for d in dungeons: d.hide()

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
	wall.polygon = shape
	wall_line.points = shape
	bg.polygon = Geometry2D.offset_polygon(offset_points(shape.duplicate()), 100)[0]

	await get_tree().process_frame

	spawn_flowers(1)
	spawn_flowers(-1)

	spawn_hut(8500)
	spawn_hut(17000)
	spawn_hut(-8500)
	spawn_hut(-17000)

	var spots := range(poly.polygon.size())
	spots.shuffle()

	for i in 50:
		var p = poly.polygon[spots[i]]
		if to_local(p).length() < 1500: continue
		var rock = rock_prefab.instantiate() as Node2D
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

	for i in 4:
		create_dungeon(0)
		await get_tree().process_frame

	for i in 200:
		var p = bg.polygon[tree_spots[i]]
		if not Geometry2D.is_point_in_polygon(p + Vector2.DOWN * 50, bg.polygon): continue
		var tree = tree_prefab.instantiate() as Node2D
		tree.scale *= randf_range(0.8, 1.2)
		trees.add_child(tree)
		tree.global_position = bg.to_global(p) + Vector2.UP * randf_range(400, 750)
		# tree.global_position.x *= -1

func create_dungeon(try := 0):
	if try > 10: return
	var p = get_ground_pos(randf_range(5000, 15000) * [-1, 1].pick_random())
	if abs(p.x) < 2000:
		create_dungeon(try + 1)
		return
	var shape = shift(dungeons.pick_random().polygon, p)
	# for i in range(shape.size()):
	# 	var pp = shape[i]
	# 	shape[i] = Vector2.ZERO + pp.rotated(randf_range(-0.1, 0.1))
	var updated := Geometry2D.clip_polygons(poly.polygon, shape)
	if updated.size() == 1:
		poly.polygon = updated[0]
		collider.polygon = updated[0]
		line.points = updated[0]
	else:
		create_dungeon(try + 1)

func get_ground_pos(pos: float) -> Vector2:
	ray.global_position = Vector2(pos, -5000)
	ray.force_raycast_update()
	return ray.get_collision_point() if ray.is_colliding() else Vector2.ZERO

func shift(shape: PackedVector2Array, dir: Vector2) -> PackedVector2Array:
	for p in range(shape.size()):
		shape[p] += dir
	return shape

func explode(pos: Vector2):
	var updated := Geometry2D.clip_polygons(poly.polygon, shift(explosion.polygon, pos))
	if updated.size() == 1:
		poly.polygon = updated[0]
		collider.polygon = updated[0]
		line.points = updated[0]
	# else:
	# 	for p in updated.size():
	# 		print("%d points" % [updated[p].size()])

func spawn_flowers(dir: float):
	var pos = dir * randf_range(4000, 6000)
	for i in 5:
		spawn_flower(pos)
		if randf() < 0.5: spawn_flower(pos + randf_range(500, 1000))
		if randf() < 0.5: spawn_flower(pos - randf_range(500, 1000))
		pos += dir * randf_range(3000, 6000)

func spawn_hut(pos: float, tries: int = 0):
	if tries > 20: return
	var spot := Vector2.ZERO
	for i in 10:
		# print("try ", i)
		spot = Vector2(global_position.x + pos + randf_range(-1000, 1000), -5000)
		ray.global_position = spot
		ray.force_raycast_update()
		if ray.is_colliding() and is_level(pos, 500): break

	if ray.is_colliding():
		var p = ray.get_collision_point()
		var hut = huts.pick_random().instantiate() as Node2D
		hut.rotate(ray.get_collision_normal().angle() + PI * 0.5 + randf_range(-0.1, 0.1))
		add_child(hut)
		hut.scale.x = [1, -1].pick_random()
		hut.global_position = p
	else:
		spawn_hut(pos + randf_range(-500, 500), tries + 1)

func is_level(pos: float, distance: float) -> bool:
	ray.global_position = Vector2(global_position.x + pos - distance, -5000)
	ray.force_raycast_update()
	if not ray.is_colliding(): return false
	var left = ray.get_collision_point()
	ray.global_position = Vector2(global_position.x + pos + distance, -5000)
	ray.force_raycast_update()
	if not ray.is_colliding(): return false
	var right = ray.get_collision_point()
	return left.distance_to(right) < 2.75 * distance

func spawn_flower(pos: float):
	ray.global_position = Vector2(global_position.x + pos, -5000)
	ray.force_raycast_update()
	if ray.is_colliding():
		var p = ray.get_collision_point()
		if not Geometry2D.is_point_in_polygon(p + Vector2.DOWN * 200, poly.polygon): return
		var flower = flower_prefab.instantiate() as Flower
		add_child(flower)
		flower.global_position = p

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
