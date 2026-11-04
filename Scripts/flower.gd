class_name Flower extends Node2D

@export var area: Area2D

func _ready() -> void:
	area.body_entered.connect(entered)
	area.body_exited.connect(exited)

func entered(_body: Node2D):
	Main.singleton.harvester.begin(area.global_position)

func exited(_body: Node2D):
	Main.singleton.harvester.hide()
