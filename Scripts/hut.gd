class_name Hut extends Node2D

enum DoorType {
	None = -1,
	Music,
	Flip,
	Bird
}

@export var door: Door
@export var poster: Sprite2D

var door_type: DoorType

func setup(normal: Vector2, hint: Texture2D, mirrored: int):
	rotate(normal.angle() + PI * 0.5 + randf_range(-0.1, 0.1))
	scale.x *= mirrored
	if poster:
		poster.scale.x *= mirrored
		poster.texture = hint
