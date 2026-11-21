class_name Weapon extends Equipment

@export var area: ShapeCast2D
@export var damage := 3

var deadly := false

func update(delta: float):
	super.update(delta)
	align()
	if deadly:
		if area.is_colliding():
			var bird_hurt := false
			var worm_hurt := false
			var done: Array = []
			if area.is_colliding():
				for i in area.get_collision_count():
					var o = area.get_collider(i)
					done.append(o)
					if o is Breakable:
						o.destroy()
						deadly = false
					if o is RootPointer:
						deadly = false
						Effects.singleton.add(8, area.global_position)
						if o.root is Worm and not worm_hurt:
							worm_hurt = true
							o.root.hurt(damage)
						if o.root is Bird and not bird_hurt:
							bird_hurt = true
							o.root.hurt(damage)

	if Input.is_action_just_pressed("primary"):
		deadly = true
		await get_tree().create_timer(0.1).timeout
		deadly = false

func toggle(state: bool):
	super.toggle(state)
