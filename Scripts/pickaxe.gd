extends Equipment

@export var area: ShapeCast2D

func update(delta: float):
	super.update(delta)
	align()
	if Input.is_action_just_pressed("primary"):
		area.global_position = get_global_mouse_position()
		await get_tree().create_timer(0.1).timeout
		if area.is_colliding():
			var done: Array = []
			if area.is_colliding():
				for i in area.get_collision_count():
					var o = area.get_collider(i)
					done.append(o)
					if o is RootPointer:
						if o.root is Rock:
							o.root.mine(area.global_position)

func toggle(state: bool):
	super.toggle(state)
