class_name Slot extends Control

@export var label: RichTextLabel

var equipment: Equipment
var item: Item

func mark(state: bool):
	if equipment: equipment.toggle(state)
	modulate = Color.WHITE if state else Color.GRAY

func add_equipment(eq: Equipment):
	equipment = eq
	label.text = eq.name.substr(0, 1)

func add_item(data: ItemData):
	item = Item.new(data)
	label.text = data.title.substr(0, 1)

func is_empty() -> bool:
	return not equipment and not item
