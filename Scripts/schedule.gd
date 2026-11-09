class_name Schedule extends Node

@export var tint: CanvasModulate
@export var ui_tint: CanvasModulate
@export var tint_color: Gradient

var time := 0.1
var speed := 0.1
var day := 1

func _process(delta) -> void:
	time += delta * speed
	if time >= 1:
		time -= 1
		day += 1
		Main.pop("DAY %d" % [day])
		for f in Main.singleton.flowers:
			f.fill()
	tint.color = tint_color.sample(time)
	ui_tint.color = tint.color + Color(0.2, 0.2, 0.2)
