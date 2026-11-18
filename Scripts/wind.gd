class_name Wind extends Line2D

var speed := 20.0
var pos := 0.0

var all: PackedVector2Array

func _ready() -> void:
	all = points

func restart(p: Vector2):
	global_position = p
	pos = 0
	speed = randf_range(10, 30)
	width = randf_range(40, 80)
	scale.y = [1, -1].pick_random()
	update()
	show()

func _process(_delta) -> void:
	if not visible: return
	pos += _delta * speed
	if pos > all.size() - 1:
		pos = 0
		hide()
	update()

func update():
	var i = roundi(pos)
	points = all.slice(i, i + 4)
