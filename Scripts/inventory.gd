class_name Inventory extends Node

@export var slot_prefab: PackedScene
@export var manager: ItemManager

var announces := false
var slots: Array[Slot] = []
var focused := 0
var other: Inventory

signal changed
signal added
signal items_moved

func create_slots(amount: int):
	for i in amount:
		var slot = slot_prefab.instantiate() as Slot
		add_child(slot)
		slots.append(slot)
		slot.mark(false)
		slot.label.text = ""
		slot.button.gui_input.connect(func(e: InputEvent): click_slot(slot, e))
		slot.changed.connect(func(): items_moved.emit())

func click_slot(slot: Slot, e: InputEvent):
	if e is InputEventMouseButton and e.pressed:
		if not other:
			focus(slots.find(slot))
			return
		slot.pick(other, e.button_index == MOUSE_BUTTON_RIGHT)

func re_focus():
	focus(focused)

func lock():
	for s in slots:
		s.locked = true

func focus(index: int):
	if focused > -1: slots[focused].mark(false)
	focused = index
	if index < 0: return
	slots[focused].mark(true)
	changed.emit()

func get_count(id: Item.Id):
	var total := 0
	for s in slots:
		if s.item and s.item.data.item_id == id:
			total += s.item.amount
	return total

func has(id: Item.Id) -> bool:
	return slots.any(func(s: Slot): return s.item and s.item.data.item_id == id)

func current() -> Slot:
	return slots[focused]

func get_free_slot() -> int:
	return slots.find_custom(func(s: Slot): return s.is_empty())

func add_equipment(eq: Equipment):
	var slot = get_free_slot()
	if slot >= 0:
		slots[slot].add_equipment(eq)
	else:
		Main.drop(null, eq)
	focus(focused)

func clear():
	for s in slots:
		s.clear()

func get_contents() -> Array[Item]:
	var contents: Array[Item] = []
	contents.resize(slots.size())
	for i in slots.size():
		if slots[i].equipment:
			contents[i] = Item.new(Main.singleton.item_db.items[Item.Id.Equipment], 1)
			contents[i].equip = slots[i].equipment.identifier
		else:
			contents[i] = slots[i].item
	return contents

func can_add_item(item: Item, equip: Equipment):
	return item and can_add(item.data.item_id, item.amount) or equip and has_space()

func has_space():
	return slots.any(func(s: Slot): return s.is_empty())

func can_add(id: Item.Id, amount: int) -> bool:
	var match = slots.find_custom(func(s: Slot): return s.can_add(id, amount))
	return match > -1 or slots.any(func(s: Slot): return s.is_empty())

func add_item(id: Item.Id, amount: int = 1):
	var match = slots.find_custom(func(s: Slot): return s.can_add(id, amount))
	var announce_distance = 100
	if match >= 0:
		amount = slots[match].increment(amount)
		if announces: Main.pop(slots[match].item.data.title, announce_distance)
	if amount > 0:
		var slot = get_free_slot()
		if slot >= 0:
			slots[slot].add_item(manager.items[id], amount)
			if announces: Main.pop(slots[slot].item.data.title, announce_distance)
		else:
			Main.singleton.item_db.spawn(id, Main.singleton.bee.body.global_position, amount)
	focus(focused)
	added.emit()

func change_focus(dir: int):
	focus((focused + dir + slots.size()) % slots.size())

func get_recipe_description(recipe: Dictionary[Item.Id, int]) -> String:
	var desc = ""
	var db = Main.singleton.item_db.items
	for id: Item.Id in recipe.keys():
		var item = db[id] as ItemData
		var have = get_count(id)
		var have_color = "#20A39E" if have >= recipe[id] else "#EF5B5B"
		desc += "[color=%s]%d[/color] x %s [img=36 color=#%s]%s[/img] (got [color=%s]%d[/color])\n" % [
			have_color,
			recipe[id],
			item.title,
			item.color.to_html(),
			item.sprite.get_path(),
			have_color,
			have
		]
	return desc

func has_materials(recipe: Dictionary[Item.Id, int]) -> bool:
	for id in recipe.keys():
		if get_count(id) < recipe[id]:
			return false
	return true

func consume_materials(recipe: Dictionary[Item.Id, int]):
	for id in recipe.keys():
		consume(id, recipe[id])

func consume_one():
	consume(current().item.data.item_id, 1)
	re_focus()

func find_first_of(list: Array[Item.Id]) -> int:
	for i in slots.size():
		for id in list:
			if slots[i].has(id):
				return list.find(id)
	return -1

func consume(id: Item.Id, amount: int):
	var left = amount
	for s in slots:
		if s.item and s.item.data.item_id == id:
			if s.item.amount >= left:
				s.take(left)
				return
			left -= s.item.amount
			s.clear()

func get_for_save() -> Array:
	var data = []
	data.resize(slots.size())
	for i in slots.size():
		data[i] = slots[i].get_for_save()
	return data

func drop(pos: Vector2):
	for slot in slots:
		if not slot.equipment:
			if not slot.item: continue
			var p = Main.drop_at(slot.item, null, pos)
			slot.clear()
			if p: p.apply_impulse(Vector2.UP.rotated(randf_range(0, 2 * PI)) * 800)
