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
	slots[focused].mark(true)
	changed.emit()

func current() -> Slot:
	return slots[focused]

func get_free_slot() -> int:
	return slots.find_custom(func(s: Slot): return s.is_empty())

func add_equipment(eq: Equipment):
	slots[get_free_slot()].add_equipment(eq)

func add_item(id: Item.Id):
	slots[get_free_slot()].add_item(manager.items[id])

func change_focus(dir: int):
	focus((focused + dir + slots.size()) % slots.size())
