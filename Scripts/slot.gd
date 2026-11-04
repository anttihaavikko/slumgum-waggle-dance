class_name Slot extends Control

@export var label: RichTextLabel
@export var count_container: Control
@export var count_label: RichTextLabel
@export var icon: TextureRect

var equipment: Equipment
var item: Item

func mark(state: bool):
	if equipment: equipment.toggle(state)
	modulate = Color.WHITE if state else Color(0.5, 0.5, 0.5)
	scale = Vector2.ONE * (1.2 if state else 1.0)

func add_equipment(eq: Equipment):
	equipment = eq
	label.text = eq.name.substr(0, 1)

func add_item(data: ItemData, amount: int = 1):
	count_container.show()
	item = Item.new(data, amount)
	increment(0)
	# label.text = data.title.substr(0, 1)
	label.hide()
	icon.show()
	icon.texture = data.sprite
	icon.self_modulate = data.color

func is_empty() -> bool:
	return not equipment and not item

func can_add(id: Item.Id, amount: int):
	return item and item.data.item_id == id and item.amount < item.data.stack_size

func increment(amount: int) -> int:
	var remains = item.amount + amount - item.data.stack_size
	item.amount = mini(item.amount + amount, item.data.stack_size)
	count_label.text = str(item.amount)
	return remains
