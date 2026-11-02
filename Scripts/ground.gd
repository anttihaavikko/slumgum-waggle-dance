extends CollisionPolygon2D

@export var poly: Polygon2D
@export var line: Line2D

func _ready() -> void:
	poly.polygon = polygon
	line.points = polygon
