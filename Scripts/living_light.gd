extends PointLight2D

var time := 0.0

func _process(delta) -> void:
	time += delta * 20.0
	texture_scale = 1.0 + sin(time) * 0.01
