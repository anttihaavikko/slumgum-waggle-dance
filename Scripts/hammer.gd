extends Equipment

@export var builder: Builder

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

func toggle(state: bool):
	super.toggle(state)
	if Main.singleton.station: return
	if state:
		builder.create(builder.slot)
	else:
		builder.clear()
