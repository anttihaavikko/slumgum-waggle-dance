extends Equipment

@export var builder: Builder

func update(delta: float):
	super.update(delta)
	align()
	if Input.is_action_just_pressed("alt"):
		builder.create((builder.slot + 1) % builder.pieces.size(), true)

func toggle(state: bool):
	super.toggle(state)
	if state:
		builder.create(builder.slot)
	else:
		builder.clear()
