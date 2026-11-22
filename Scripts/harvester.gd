class_name Harvester extends Node2D

@export var marker: ColorRect
@export var marker_end: Control
@export var icon: Control
@export var bad: Control
@export var good: Control
@export var arrow: Control

var start: float
var end: float

var pos := 0.0
var moving := true
var done := false
var flower: Flower

func _ready() -> void:
	hide()
	start = marker.position.x
	end = marker_end.position.x

func begin(f: Flower, p: Vector2):
	flower = f
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
		SoundEffects.singleton.add(2 if success else 3, Main.singleton.bee.body.global_position)
		icon.position = marker.position
		bad.visible = not success
		good.visible = success
		# arrow.self_modulate = good.self_modulate if success else Color.WHITE
		done = true
		if success:
			flower.consume()
			Main.singleton.inventory.add_item(Item.Id.Nectar)
			if Main.singleton.bee.is_holding(Equipment.Id.Brush):
				Main.singleton.inventory.add_item(Item.Id.Pollen)

func reset():
	pos = 0
	bad.hide()
	good.hide()
	done = false
	arrow.self_modulate = Color.WHITE
