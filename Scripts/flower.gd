class_name Flower extends Node2D

@export var area: Area2D
@export var center: Sprite2D

var amount := 0

func _ready() -> void:
	area.global_position.y += randf_range(-400, 200)
	area.body_entered.connect(entered)
	area.body_exited.connect(exited)
	fill()

func fill():
	amount = randi_range(3, 5)
	center.modulate = Color.WHITE

func consume():
	amount -= 1
	if amount == 0:
		var c = 0.8
		center.modulate = Color(c, c, c)
		Main.pop("ALL HARVESTED")
		await get_tree().create_timer(0.5).timeout
		Main.singleton.harvester.hide()

func entered(_body: Node2D):
	if amount <= 0:
		Main.pop("NOTHING LEFT")
		return
	Main.singleton.harvester.begin(self, area.global_position)

func exited(_body: Node2D):
	var h := Main.singleton.harvester
	if h.flower == self:
		h.hide()
