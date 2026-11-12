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
				var dir = o.global_position - global_position
				var magniude = clampf(1500.0 - dir.length(), 0, 1500.0)
				var damage = roundi(magniude / 1500.0 * 9.0)
				if o is Breakable:
					o.destroy()
				if o is RigidBody2D:
					var mod = 1.0
					if o is RootPointer:
						if o.owner is Worm:
							o.owner.hurt(10)
						if o.owner is Bird:
							o.owner.hurt(10)
					if o.get_parent() is Bee and o is not Bomb:
						var bee = o.get_parent() as Bee
						mod *= 2
						if magniude > 1000: bee.damage(damage)
					o.apply_impulse(dir.normalized() * magniude * mod)
	var exploded := false
	for island in Main.singleton.islands:
		exploded = exploded or island.explode(island.to_local(global_position))
	Main.shake(40, 0.3)
	Effects.singleton.add_many([1, 2, 3], global_position)
	if shape.get_collision_count() > 0 and exploded:
		for i in 10:
			var dirt = Main.spawn_item([Item.Id.Sand, Item.Id.Dirt].pick_random(), global_position)
			dirt.apply_impulse(Vector2.ONE.rotated(randf() * PI * 2) * randf_range(500, 1200))
	queue_free()
