class_name Painter extends Equipment

@export var paint: Node2D
@export var colors: Array[Color]
@export var cast: ShapeCast2D

var current := 0
var paints := [Item.Id.PaintWhite, Item.Id.PaintRed, Item.Id.PaintGreen, Item.Id.PaintYellow]
var paint_names := ["WHITE", "RED", "GREEN", "YELLOW"]

func update(_delta: float):
	super.update(_delta)
	align()
	if Input.is_action_just_pressed("alt"):
		current = (current + 1) % colors.size()
		paint.self_modulate = colors[current]
	if Input.is_action_just_pressed("primary"):
		var needs = paints[current]
		if not Main.singleton.inventory.has(needs):
			Main.pop("NO %s PAINT!" % [paint_names[current]])
			SoundEffects.singleton.add(10, global_position, 1)
			return
		if cast.is_colliding():
			SoundEffects.singleton.add(44, global_position, 1)
			Main.singleton.inventory.consume(paints[current], 1)
			var c = cast.get_collider(0)
			try_to_paint(c)
			try_to_paint(c.get_parent())

func blocks_clicks() -> bool:
	return true

func try_to_paint(target: Node):
	if target is BuildPiece:
		target.paint_color = current
		paint_piece(target, paint.self_modulate)

static func paint_piece(target: Node, color: Color):
	if target is BuildPiece and target.sprite:
		if not target.can_paint: return
		for s in target.extra_sprites:
			s.self_modulate = color
		if target.sprite is Line2D:
			target.sprite.default_color = color
		if target.sprite is Sprite2D:
			target.sprite.self_modulate = color
