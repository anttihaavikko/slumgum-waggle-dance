extends Equipment

func update(delta: float):
	super.update(delta)
	align()

func toggle(state: bool):
	super.toggle(state)
