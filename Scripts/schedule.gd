class_name Schedule extends Node

@export var tint: CanvasModulate
@export var ui_tint: CanvasModulate
@export var tint_color: Gradient
@export var globe_tint: ColorRect

var sleeper: Node2D

var time := 0.1
var speed := 0.005
var day := 1
var sleep_until := -1.0

func _process(delta) -> void:
	time += delta * speed
	if time >= 1:
		time -= 1
		day += 1
		Engine.time_scale = 1.0
		if sleeper: sleeper.hide()
		Main.singleton.rank += 1
		Main.singleton.bee.show()
		Effects.singleton.pop("[font_size=200]DAY %d" % [day], Main.singleton.bee.body.global_position + Vector2.UP * 700)
		Main.singleton.cleanup()
		for f in Main.singleton.flowers:
			if f: f.fill()
	tint.color = tint_color.sample(time)
	ui_tint.color = tint.color + Color(0.2, 0.2, 0.2)
	globe_tint.color = tint.color.lightened(0.1)

func _unhandled_key_input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey:
			if Input.is_key_pressed(KEY_T):
				time += 0.2

func sleep_until_morning():
	if sleeper.global_position.distance_to(Main.singleton.bee.body.global_position) > 300:
		Main.pop("TOO FAR!")
		return
	if time < 0.5:
		Main.pop("TOO EARLY!")
		return
	Engine.time_scale = 10.0
	sleep_for(0)
	sleeper.show()
	Main.singleton.bee.hide()

func sleep_eight():
	sleep_for(1.0 / 3)

func sleep_for(amount: float):
	time += amount
	if Main.singleton.station:
		Main.singleton.station.close()
