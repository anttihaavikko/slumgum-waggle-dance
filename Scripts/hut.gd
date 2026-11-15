class_name Hut extends Node2D

enum DoorTypes {
	Music,
	Bird,
	Flip
}

@export var door: Door
@export var poster: Sprite2D

func setup(normal: Vector2, hint: Texture2D):
	rotate(normal.angle() + PI * 0.5 + randf_range(-0.1, 0.1))
	if poster: poster.texture = hint
