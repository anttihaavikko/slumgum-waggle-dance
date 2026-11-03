class_name Slot extends Control

@export var label: RichTextLabel

var equipment: Equipment

func mark(state: bool):
	if equipment: equipment.toggle(state)
	modulate = Color.WHITE if state else Color.GRAY

func add_equipment(eq: Equipment):
	equipment = eq
	label.text = eq.name.substr(0, 1)

func is_empty() -> bool:
	print(equipment)
	return not equipment
