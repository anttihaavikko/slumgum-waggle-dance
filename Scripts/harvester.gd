class_name Harvester extends Node2D

@export var marker: ColorRect
@export var marker_end: Control
@export var icon: Control
@export var bad: Control
@export var good: Control

var start: float
var end: float

var pos := 0.0
var moving := true
var done := false

func _ready() -> void:
	hide()
	start = marker.position.x
	end = marker_end.position.x

func begin(p: Vector2):
	reset()
	global_position = p
	show()

func _process(delta) -> void:
	if not visible or not moving: return
	pos = clampf(pos + delta, 0, 1)
	if pos >= 1: reset()
	marker.position.x = lerpf(start, end, pos)
	if done: return
	if Input.is_action_just_pressed("accelerate"):
		var success := absf(0.5 - pos) < 0.075
		icon.position = marker.position
		bad.visible = not success
		good.visible = success
		done = true
		if success:
			Main.singleton.inventory.add_item(Item.Id.Nectar)

func reset():
	pos = 0
	bad.hide()
	good.hide()
	done = false
