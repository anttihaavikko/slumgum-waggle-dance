class_name Island extends Node2D

@export var shapes: Array[Polygon2D]

@export var collider: CollisionPolygon2D
@export var poly: Polygon2D
@export var line: Line2D
@export var bg: Polygon2D

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
