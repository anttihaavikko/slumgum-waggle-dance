extends Equipment

@export var area: ShapeCast2D

func update(delta: float):
	super.update(delta)
	align()
	if Input.is_action_just_pressed("primary"):
		await get_tree().create_timer(0.1).timeout
		if area.is_colliding():
			var done: Array = []
			if area.is_colliding():
				for i in area.get_collision_count():
					var o = area.get_collider(i)
					done.append(o)
					if o is Breakable:
						o.destroy()
					if o is RootPointer:
						Effects.singleton.add(8, area.global_position)
						if o.root is Worm:
							o.root.hurt(3)
						if o.root is Bird:
							o.root.hurt(3)

func toggle(state: bool):
	super.toggle(state)
