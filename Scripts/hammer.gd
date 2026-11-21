extends Equipment

@export var builder: Builder
@export var cast: ShapeCast2D

func update(delta: float):
	super.update(delta)
	align()
	if Input.is_action_just_pressed("alt"):
		builder.open_menu()
		# builder.create((builder.slot + 1) % builder.pieces.size(), true)
	if Input.is_action_just_pressed("cancel"):
		if builder and builder.held:
			builder.clear()
		if builder and builder.picker.visible:
			builder.close()
	if Input.is_action_just_pressed("middle"):
		if cast.is_colliding():
			var c = cast.get_collider(0)
			try_to_break(c)
			try_to_break(c.get_parent())

func toggle(state: bool):
	super.toggle(state)
	if Main.singleton.station: return
	if state:
		builder.create(builder.slot)
	else:
		builder.clear()

func try_to_break(target: Node):
	if target is BuildPiece:
		if not target.can_break:
			Main.pop("CAN NOT DESTROY THAT!")
		else:
			if target is Station:
				target.drop_items()
			var items = builder.pieces[target.identifier].recipe
			for id in items:
				var item = Main.spawn_item(id, target.center.global_position if target is Station else target.global_position)
				item.apply_impulse(Vector2.ONE.rotated(randf() * TAU) * 200 + Vector2.UP * 200)
			Effects.singleton.add(3, target.global_position)
			Main.shake(15, 0.2)
			builder.remove_piece(target)
			target.queue_free()
