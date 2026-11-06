class_name Flower extends Node2D

@export var area: Area2D

func _ready() -> void:
	area.body_entered.connect(entered)
	area.body_exited.connect(exited)

func entered(_body: Node2D):
	Main.singleton.harvester.begin(self, area.global_position)

func exited(_body: Node2D):
	var h := Main.singleton.harvester
	if h.flower == self:
		h.hide()
