extends Equipment

@export var builder: Builder

func update(delta: float):
	super.update(delta)
	align()
	if Input.is_action_just_pressed("alt"):
		builder.clear()
		builder.picker.show()
		builder.preview.show()
		# builder.create((builder.slot + 1) % builder.pieces.size(), true)
	if Input.is_action_just_pressed("cancel"):
		if builder: builder.close()

func toggle(state: bool):
	super.toggle(state)
	if Main.singleton.station: return
	if state:
		builder.create(builder.slot)
	else:
		builder.clear()
