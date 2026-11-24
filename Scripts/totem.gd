class_name Totem extends Node2D

@export var sprite: Sprite2D

func _process(_delta) -> void:
	var dir = (Main.bee_pos() - global_position).normalized()
	sprite.position = dir * 50

func setup(item: Item.Id):
	if item in [Item.Id.EyeRobin, Item.Id.EyeBeeEater, Item.Id.EyeGreatTit, Item.Id.EyeShrike]:
		sprite.texture = Main.get_item_data(item).sprite
		sprite.show()
