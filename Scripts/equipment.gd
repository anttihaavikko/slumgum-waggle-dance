@abstract class_name Equipment extends Node2D

enum Type {
	Hammer,
	Scythe
}

func update(_delta: float):
	pass

func toggle(state: bool):
	visible = state
