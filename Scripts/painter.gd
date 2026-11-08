extends Equipment

@export var paint: Node2D
@export var colors: Array[Color]
@export var cast: ShapeCast2D

var current := 0

func update(_delta: float):
	super.update(_delta)
	align()
	if Input.is_action_just_pressed("alt"):
		current = (current + 1) % colors.size()
		paint.self_modulate = colors[current]
	if Input.is_action_just_pressed("primary"):
		if cast.is_colliding():
			var c = cast.get_collider(0)
			try_to_paint(c)
			try_to_paint(c.get_parent())

func blocks_clicks() -> bool:
	return true

func try_to_paint(target: Node):
	if target is BuildPiece and target.sprite:
		if target.sprite is Line2D:
			target.sprite.default_color = paint.self_modulate
		if target.sprite is Sprite2D:
			target.sprite.self_modulate = paint.self_modulate
