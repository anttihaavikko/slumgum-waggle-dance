extends Polygon2D

@export var area: Area2D
@export var line: Line2D

var noise = FastNoiseLite.new()
var level := 0.0
var time := 0.0
var point_amount := 300
var wave_height := 200

func _ready() -> void:
	area.body_entered.connect(enter)
	var start = polygon[0]
	var end = polygon[1]
	var points: PackedVector2Array = []
	level = polygon[0].y
	for i in point_amount:
		points.append(lerp(start, end, i * 1.0 / point_amount))
	points.append(polygon[2])
	points.append(polygon[3])
	polygon = points
	line.points = points

func enter(node: Node2D):
	Effects.singleton.add(3, node.global_position)
	if node is BeeBody and Main.singleton.bee.health.is_alive():
		Main.singleton.bee.die()

func _process(delta) -> void:
	time += delta * 20
	var points = polygon
	for i in point_amount:
		points[i] = Vector2(points[i].x, level + noise.get_noise_2d(i * 10, time) * wave_height + sin(i + time) + wave_height)
	polygon = points
	line.points = points
