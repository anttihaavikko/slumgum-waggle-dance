class_name Totem extends Node2D

@export var sprite: Sprite2D

var compass := false

func _process(_delta) -> void:
	var dir = (Main.bee_pos() - global_position).normalized()
	if compass: dir = Main.singleton.get_compass_dir(global_position) * 2
	sprite.position = dir * 50

func setup(item: Item.Id):
	compass = item == Item.Id.EyeRobin
	if item in [Item.Id.EyeRobin, Item.Id.EyeBeeEater, Item.Id.EyeGreatTit, Item.Id.EyeShrike]:
		sprite.texture = Main.get_item_data(item).sprite
		sprite.show()
