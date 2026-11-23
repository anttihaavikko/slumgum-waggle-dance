class_name Flower extends Node2D

@export var area: Area2D
@export var center: Sprite2D
@export var mover: Mover
@export var breakable: Breakable

var amount := 0
var grown := false
var index_number := -1

func _ready() -> void:
	mover.time_offset = randf_range(0, 100)
	area.global_position.y += randf_range(-400, 200)
	area.body_entered.connect(entered)
	area.body_exited.connect(exited)
	fill()
	Main.singleton.flowers.append(self)
	breakable.broke.connect(broke)
	if Main.singleton.data.broken_nodes.has(index_number * 1.0):
		queue_free()

func broke():
	if index_number >= 0:
		Main.singleton.data.broken_nodes.append(index_number)

func fill():
	amount = randi_range(3, 5) * breakable.drop_multiplier
	center.modulate = Color.WHITE

func consume():
	amount -= 1
	if amount == 0:
		var c = 0.8
		center.modulate = Color(c, c, c)
		Main.pop("[font_size=150]ALL HARVESTED", 200)
		SoundEffects.singleton.add(4, global_position, 2)
		await get_tree().create_timer(0.5).timeout
		Main.singleton.harvester.hide()

func entered(_body: Node2D):
	if amount <= 0:
		Main.pop("NOTHING LEFT")
		SoundEffects.singleton.add(4, global_position, 2)
		return
	Main.singleton.harvester.begin(self, area.global_position)

func exited(_body: Node2D):
	var h := Main.singleton.harvester
	if h.flower == self:
		h.hide()
