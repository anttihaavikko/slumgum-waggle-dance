class_name BuildPiece extends Node2D

@export var body: StaticBody2D
@export var can_rotate := true
@export var connection_shapes: Array[ShapeCast2D]
@export var required_shape: ShapeCast2D

func can_place() -> bool:
	return is_attached() and not is_blocked()

func is_attached() -> bool:
	return connection_shapes.all(func(c: ShapeCast2D): return c.is_colliding()) if connection_shapes.size() > 0 else true

func is_blocked() -> bool:
	return required_shape.is_colliding() if required_shape else false
