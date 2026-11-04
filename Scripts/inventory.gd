class_name Inventory extends Node

@export var slot_prefab: PackedScene
@export var manager: ItemManager

var slots: Array[Slot] = []
var focused := 0

signal changed

func create_slots(amount: int):
	for i in amount:
		var slot = slot_prefab.instantiate() as Slot
		add_child(slot)
		slots.append(slot)
		slot.mark(false)
		slot.label.text = ""

func focus(index: int):
	if focused > -1: slots[focused].mark(false)
	focused = index
	if index < 0: return
	slots[focused].mark(true)
	changed.emit()

func current() -> Slot:
	return slots[focused]

func get_free_slot() -> int:
	return slots.find_custom(func(s: Slot): return s.is_empty())

func add_equipment(eq: Equipment):
	slots[get_free_slot()].add_equipment(eq)
	focus(focused)

func can_add(id: Item.Id, amount: int):
	var match = slots.find_custom(func(s: Slot): return s.can_add(id, amount))
	return match > -1 or slots.any(func(s: Slot): return s.is_empty())

func add_item(id: Item.Id, amount: int = 1):
	var match = slots.find_custom(func(s: Slot): return s.can_add(id, amount))
	if match >= 0:
		amount = slots[match].increment(amount)
	if amount > 0:
		var slot = get_free_slot()
		if slot >= 0:
			slots[slot].add_item(manager.items[id], amount)
		else:
			Main.singleton.item_db.spawn(id, Main.singleton.bee.body.global_position, amount)
	focus(focused)

func change_focus(dir: int):
	focus((focused + dir + slots.size()) % slots.size())
