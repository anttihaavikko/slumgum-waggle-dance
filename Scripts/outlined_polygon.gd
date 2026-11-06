class_name OutlinedPolygon extends Node2D

@export var poly: Polygon2D
@export var line: Line2D

var polygon: PackedVector2Array:
	set(val):
		polygon = val
		poly.polygon = val
		line.points = val
