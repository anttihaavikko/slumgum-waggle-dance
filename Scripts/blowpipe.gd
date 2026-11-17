extends Equipment

@export var ray: RayCast2D
@export var line: Line2D
@export var particles: CPUParticles2D

var can_shoot := true

func update(_delta: float):
	super.update(_delta)
	align()
	if Input.is_action_just_pressed("primary") and can_shoot:
		var ammo = Item.Id.Seed
		can_shoot = false
		var pos = line.to_local(ray.get_collision_point()) if ray.is_colliding() else ray.target_position
		line.set_point_position(1, pos)
		line.show()
		Main.shake(10, 0.1)
		particles.emitting = true
		var body = Main.singleton.bee.body
		body.apply_impulse(-ray.position.normalized().rotated(aligner.rotation) * 400)
		if ray.is_colliding():
			var hit = ray.get_collider()
			var p = ray.get_collision_point()
			Effects.singleton.add(3, p)
			var n = ray.get_collision_normal()
			if hit is StaticBody2D:
				var a = Main.spawn_item(ammo, p)
				a.apply_impulse(n * randf_range(300, 1000))
				await get_tree().process_frame
				a.apply_torque_impulse(randf_range(-1, 1) * 2000)
			if hit is RigidBody2D:
				hit.apply_impulse(-n * 500)
			if hit is RootPointer:
				if hit.root is Worm or hit.root is Bird:
					Effects.singleton.add(8, p)
					hit.root.hurt(1)
		await get_tree().create_timer(0.1).timeout
		line.hide()
		await get_tree().create_timer(0.1).timeout
		can_shoot = true

func toggle(state: bool):
	super.toggle(state)
