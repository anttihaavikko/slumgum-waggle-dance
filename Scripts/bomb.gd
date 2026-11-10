class_name Bomb extends RigidBody2D

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	var shape := Main.singleton.explosion_shape
	shape.global_position = global_position
	shape.force_shapecast_update()
	var done: Array = []
	if shape.is_colliding():
		for i in shape.get_collision_count():
			var o = shape.get_collider(i)
			if o not in done:
				done.append(o)
				if o is RigidBody2D:
					var dir = o.global_position - global_position
					var magniude = clampf(1500.0 - dir.length(), 0, 1500.0)
					var mod = 1.0
					if o.get_parent() is Bee and o is not Bomb:
						print(o.name)
						var bee = o.get_parent() as Bee
						mod *= 2
						if magniude > 1000: bee.damage(roundi(magniude / 1500.0 * 9.0))
					o.apply_impulse(dir.normalized() * magniude * mod)
	for island in Main.singleton.islands:
		island.explode(island.to_local(global_position))
	Main.shake(40, 0.3)
	Effects.singleton.add_many([1, 2, 3], global_position)
	queue_free()
