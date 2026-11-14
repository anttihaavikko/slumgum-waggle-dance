class_name Slot extends Control

@export var label: RichTextLabel
@export var count_container: Control
@export var count_label: RichTextLabel
@export var icon: TextureRect
@export var button: Button

var equipment: Equipment
var item: Item
var in_bar: bool
var depositing := false

func mark(state: bool):
	if equipment and in_bar: equipment.toggle(state)
	modulate = Color.WHITE if state else Color(0.5, 0.5, 0.5)
	scale = Vector2.ONE * (1.2 if state and in_bar else 1.0)

func has_item(id: Item.Id) -> bool:
	return item and item.data.item_id == id

func add_equipment(eq: Equipment):
	equipment = eq
	update_visuals()

func take(amt: int):
	item.amount -= amt
	if item.amount == 0: clear()
	update_visuals()

func pick(target: Inventory, alt: bool):
	var held: Slot = Main.singleton.held
	if not alt: depositing = false
	if alt and item and item.amount > 0 and not depositing:
		if held.is_empty():
			held.add_item(item.data, 1)
			take(1)
			Main.singleton.held.hide_if_empty()
			return
		if held.item.data.item_id == item.data.item_id:
			held.increment(1)
			take(1)
			return
		return
	if Input.is_action_pressed("shift"):
		if target.can_add_item(item, equipment):
			if equipment:
				target.add_equipment(equipment)
			else:
				target.add_item(item.data.item_id, item.amount)
			clear()
		return
	if not held.is_empty():
		if alt:
			depositing = true
			if item and item.data.item_id == held.item.data.item_id:
				increment(1)
			else:
				add_item(held.item.data, 1)
			held.take(1)
			if held.is_empty(): depositing = false
			Main.singleton.held.hide_if_empty()
			return
		swap(held)
		return
	held.swap(self)

func clear():
	if not in_bar: mark(false)
	if equipment: equipment.hide()
	depositing = false
	item = null
	equipment = null
	update_visuals()
	Main.singleton.inventory.re_focus()

func swap(slot: Slot):
	if slot.item and can_add(slot.item.data.item_id, slot.item.amount):
		increment(slot.item.amount)
		slot.clear()
		Main.singleton.held.hide_if_empty()
		return
	var ti = item
	var te = equipment
	item = slot.item
	equipment = slot.equipment
	update_visuals()
	mark(not in_bar)
	# slot.clear()
	slot.item = ti
	slot.equipment = te
	if equipment: equipment.hide()
	if slot.equipment: slot.equipment.hide()
	slot.update_visuals()
	Main.singleton.inventory.re_focus()
	Main.singleton.held.hide_if_empty()

func hide_if_empty():
	visible = not is_empty()

func update_visuals():
	label.visible = !!equipment
	if not in_bar: mark(item or equipment)
	if equipment:
		label.text = equipment.name.substr(0, 1)
	icon.visible = !!item
	count_container.visible = !!item
	if item:
		icon.texture = item.data.sprite
		icon.self_modulate = item.data.color
		increment(0)

func add_item(data: ItemData, amount: int = 1):
	count_container.show()
	item = Item.new(data, amount)
	update_visuals()

func drop() -> Pickup:
	var p = Main.drop(item, equipment)
	clear()
	return p

func is_empty() -> bool:
	return not equipment and (not item or item.amount == 0)

func can_add(id: Item.Id, amount: int):
	return item and item.data.item_id == id and item.amount < item.data.stack_size

func increment(amount: int) -> int:
	var remains = item.amount + amount - item.data.stack_size
	item.amount = mini(item.amount + amount, item.data.stack_size)
	count_label.text = str(item.amount)
	return remains
