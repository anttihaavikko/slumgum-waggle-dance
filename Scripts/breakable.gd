class_name Breakable extends StaticBody2D

@export var drops: Array[Item.Id]
@export var target: Node2D

func destroy():
	for d in drops:
		Main.spawn_item(d, global_position)
	target.queue_free()
