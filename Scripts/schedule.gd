class_name Schedule extends Node

@export var tint: CanvasModulate
@export var ui_tint: CanvasModulate
@export var tint_color: Gradient

var time := 0.1
var speed := 0.01
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

func _unhandled_key_input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey:
			if Input.is_key_pressed(KEY_T):
				time += 0.2

func sleep_until_morning():
	sleep_for(1.0 - time)

func sleep_eight():
	sleep_for(1.0 / 3)

func sleep_for(amount: float):
	time += amount
	if Main.singleton.station:
		Main.singleton.station.close()
