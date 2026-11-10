class_name Breakable extends StaticBody2D

@export var drops: Array[Item.Id]
@export var target: Node2D

func destroy():
	for d in drops:
		var p = Main.spawn_item(d, global_position)
		p.apply_impulse(Vector2.ONE.rotated(2 * PI * randf()) * randf_range(0, 1000))
	Effects.singleton.add(1, global_position)
	target.queue_free()
