class_name BuildPiece extends Node2D

@export var identifier: BuildPiece.Id
@export var body: StaticBody2D
@export var can_rotate := true
@export var connection_shapes: Array[ShapeCast2D]
@export var required_shape: ShapeCast2D
@export var takes_space := true
@export var label: RichTextLabel

enum Id {
	Platform,
	Support,
	Core,
	Box,
	Sign
}

func can_place() -> bool:
	return is_attached() and not is_blocked()

func is_attached() -> bool:
	return connection_shapes.all(func(c: ShapeCast2D): return c.is_colliding()) if connection_shapes.size() > 0 else true

func is_blocked() -> bool:
	return required_shape.is_colliding() if takes_space and required_shape else false

func try_to_place():
	if not is_attached():
		Main.pop("Not attached!")
		return
	if is_blocked():
		Main.pop("Blocked!")
		return
