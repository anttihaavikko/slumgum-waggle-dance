extends Equipment

@export var paint: Node2D
@export var colors: Array[Color]

var current := 0

func update(_delta: float):
	super.update(_delta)
	align()
	if Input.is_action_just_pressed("alt"):
		current = (current + 1) % colors.size()
		paint.self_modulate = colors[current]
