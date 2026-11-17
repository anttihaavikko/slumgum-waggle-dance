extends Equipment

func update(_delta: float):
	super.update(_delta)
	align()

func toggle(state: bool):
	super.toggle(state)
