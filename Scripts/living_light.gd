extends PointLight2D

var time := 0.0
var size := 1.0

func _ready() -> void:
	size = texture_scale

func _process(delta) -> void:
	time += delta * 20.0
	texture_scale = size + sin(time) * 0.01
	energy = 1.0 + sin(time) * 0.006
