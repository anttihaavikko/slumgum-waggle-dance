class_name Breakable extends StaticBody2D

@export var drops: Array[Item.Id]
@export var target: Node2D
@export var particle_points: Array[Node2D]
@export var particle_indices: Array[int]

var drop_multiplier := 1

signal broke

func destroy():
	for i in drop_multiplier:
		for d in drops:
			var p = Main.spawn_item(d, global_position)
			p.apply_impulse(Vector2.ONE.rotated(2 * PI * randf()) * randf_range(0, 1000))
	for i in particle_points.size():
		Effects.singleton.add(1, particle_points[i].global_position)
		Effects.singleton.add(particle_indices[i], particle_points[i].global_position)
	SoundEffects.singleton.add(45, global_position, 1.5)
	Main.shake(15, 0.15)
	broke.emit()
	target.queue_free()
