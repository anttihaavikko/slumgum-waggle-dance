class_name Slot extends Control

@export var label: RichTextLabel
@export var count_container: Control
@export var count_label: RichTextLabel
@export var icon: TextureRect
@export var button: Button
@export var key_container: Control
@export var key_label: RichTextLabel
@export var frame: TextureRect

var equipment: Equipment
var item: Item
var in_bar: bool
var depositing := false
var locked := false

signal changed

func _ready() -> void:
	button.mouse_entered.connect(hover_on)
	button.mouse_exited.connect(hover_off)

func hover_on():
	if Main.singleton.held == self: return
	Main.singleton.tooltip.show_for(self, global_position)

func hover_off():
	Main.singleton.tooltip.hide()

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

func mark_for_pad(state: bool):
	frame.self_modulate = Color.html("#EF5B5B") if state else Color.WHITE
	SoundEffects.singleton.add(46, global_position, 0.5)

func check():
	if not visible:
		drop()

func auto_move(target: Inventory):
	if target.can_add_item(item, equipment):
		if equipment:
			target.add_equipment(equipment)
		else:
			target.add_item(item.data.item_id, item.amount)
		clear()
		changed.emit()
		hover_off()
		Main.singleton.inventory.re_focus()

func pick(target: Inventory, alt: bool):
	var held: Slot = Main.singleton.held
	if not alt: depositing = false
	if alt and item and item.amount > 0 and not depositing:
		if held.is_empty():
			held.add_item(item.data, 1)
			held.changed.emit()
			take(1)
			Main.singleton.held.hide_if_empty()
			return
		if held.item.data.item_id == item.data.item_id:
			held.increment(1)
			take(1)
			return
		return
	if Input.is_action_pressed("shift"):
		auto_move(target)
		return
	if not held.is_empty():
		if locked: return
		if alt:
			depositing = true
			if item and item.data.item_id == held.item.data.item_id:
				increment(1)
			else:
				add_item(held.item.data, 1)
				changed.emit()
			held.take(1)
			if held.is_empty(): depositing = false
			Main.singleton.held.hide_if_empty()
			hover_on()
			return
		swap(held)
		hover_on()
		return
	held.swap(self)
	hover_on()

func clear():
	if not in_bar: mark(false)
	if equipment: equipment.hide()
	depositing = false
	item = null
	equipment = null
	update_visuals()
	if equipment and in_bar: Main.singleton.inventory.re_focus()

func get_for_save() -> Array[int]:
	if equipment: return [Item.Id.Equipment, 1, equipment.identifier]
	if not item: return []
	return [item.data.item_id, item.amount, item.equip]

func swap(slot: Slot):
	if slot.item and can_add(slot.item.data.item_id, slot.item.amount):
		var left = increment(slot.item.amount)
		slot.item.amount = left
		slot.update_visuals()
		if slot.item.amount <= 0: slot.clear()
		Main.singleton.held.hide_if_empty()
		changed.emit()
		slot.changed.emit()
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
	changed.emit()
	slot.changed.emit()

func hide_if_empty():
	visible = not is_empty()

func update_visuals():
	label.visible = !!equipment
	if not in_bar: mark(item or equipment)
	if equipment:
		icon.texture = equipment.icon
		icon.self_modulate = equipment.self_modulate
		label.text = "" if equipment.icon else equipment.name.substr(0, 1)

		# if in_bar: Main.singleton.inventory.re_focus()
	icon.visible = !!item or equipment and equipment.icon
	count_container.visible = !!item
	if item:
		icon.texture = item.data.sprite
		icon.self_modulate = item.data.color
		increment(0)

func add_item(data: ItemData, amount: int = 1, emits := true):
	if amount < 1:
		clear()
		return
	if in_bar: Main.singleton.mark_seen(data.item_id)
	count_container.show()
	item = Item.new(data, amount)
	update_visuals()
	if emits: changed.emit()

func drop() -> Pickup:
	if not item and not equipment: return
	var p = Main.drop(item, equipment)
	clear()
	return p

func is_empty() -> bool:
	return not locked and not equipment and (not item or item.amount == 0)

func has(id: Item.Id):
	return item and item.data.item_id == id

func can_add(id: Item.Id, amount: int) -> bool:
	if locked: return false
	return item and item.data.item_id == id and item.amount < item.data.stack_size

func increment(amount: int) -> int:
	var remains = item.amount + amount - item.data.stack_size
	item.amount = mini(item.amount + amount, item.data.stack_size)
	count_label.text = str(item.amount)
	return remains

func show_key(key: String):
	key_container.show()
	key_label.text = key

func get_title() -> String:
	if equipment:
		return equipment.name
	return item.data.title

func get_description() -> String:
	if equipment:
		return equipment.description
	return item.data.description
