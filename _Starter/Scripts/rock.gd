extends Node2D

@export var poly: Polygon2D
@export var line: Line2D
@export var collider: CollisionPolygon2D
@export var tint: Color

func _ready() -> void:
	rotate(PI * randf_range(-2, 2))
	var changed = poly.polygon.duplicate()
	for i in changed.size():
		var diff = 50.0 if randf() < 0.8 else 100.0
		changed[i] += Vector2(randf_range(-diff, diff), randf_range(-diff, diff))
	poly.polygon = changed
	if randf() < 0.5:
		poly.polygon = Geometry2D.offset_polygon(poly.polygon, randf_range(-50, 100))[0]
	line.points = poly.polygon
	collider.polygon = poly.polygon
	poly.self_modulate = lerp(Color.WHITE, tint, randf())
