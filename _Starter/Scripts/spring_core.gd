class_name SpringCore extends Node2D

@export var core: AnimatableBody2D
@export var target: RigidBody2D

func get_direction() -> Vector2:
	return core.global_position - target.global_position
