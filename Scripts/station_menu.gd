class_name StationMenu extends Control

@export var inputs: Inventory
@export var outputs: Inventory
@export var win: GameWindow
@export var preview: Preview
@export var description: RichTextLabel
@export var crafter: Crafter
@export var input_label: RichTextLabel
@export var output_label: RichTextLabel

var initialized: bool
var station: Station
var focused_slot_index: int
var focused_inventory: Inventory
var focused_slot: Slot
var inventories: Array[Inventory]
var can_craft := false

func _ready() -> void:
	win.hide()
	win.closed.connect(close)
	if inputs: inputs.added.connect(inventory_changed)
	if outputs: outputs.added.connect(inventory_changed)
	if inputs: inputs.items_moved.connect(inventory_changed)
	if outputs: outputs.items_moved.connect(inventory_changed)

func update_previews():
	if station:
		station.update_previews()

func move_held_with_pad():
	if focused_slot and Main.singleton.held and Main.singleton.input_detection.using_pad:
		Main.singleton.held.global_position = focused_slot.global_position + Vector2(30, -30)

func _process(_delta) -> void:
	if visible and Input.is_action_just_pressed("primary"):
		if focused_slot and focused_inventory.other: focused_slot.auto_move(focused_inventory.other)
	if visible and crafter and can_craft and Input.is_action_just_pressed("interact"):
		crafter.preview.craft()
	if visible and Input.is_action_just_pressed("interact"):
		if focused_slot: focused_slot.pick(focused_inventory, false)
		move_held_with_pad()
	if visible and Input.is_action_just_pressed("cancel"):
		close()

func inventory_changed():
	if station:
		station.pull_contents()
		station.try_convert()

func is_open() -> bool:
	return win.visible

func close():
	if preview: preview.close()
	if not win.visible: return
	if focused_slot:
		focused_slot.hover_off()
		focused_slot.mark_for_pad(false)
		focused_slot = null
	win.hide()
	Main.singleton.inventory.other = null
	Main.singleton.station = null
	if station and inputs: station.inputs = inputs.get_contents()
	if station and outputs: station.outputs = outputs.get_contents()
	if station:
		station.try_convert()
		station.update_previews()
	if Main.singleton.held:
		Main.singleton.held.drop()
		Main.singleton.held.hide()
	Main.singleton.evaluate_stats()
	can_craft = false

func open(source: Station):
	if Main.singleton.station:
		Main.singleton.station.close()
	if crafter: crafter.open()
	station = source
	Main.singleton.station = self
	Main.singleton.inventory.other = inputs
	if inputs: inputs.other = Main.singleton.inventory
	if outputs: outputs.other = Main.singleton.inventory
	if description: description.text = Utils.colorize(source.description, "#FFBA49")
	win.show()
	if preview: preview.open()

	try_init()

	if inputs: limit_slots(inputs, source.slots)
	if outputs: limit_slots(outputs, source.slots)

	update_contents()
	station.try_convert()

	if Main.singleton.input_detection.using_pad:
		inventories = []
		if focused_slot: focused_slot.mark_for_pad(false)
		await get_tree().create_timer(0.1).timeout
		focused_slot_index = 0
		if inputs:
			focused_inventory = inputs
			inventories.append(inputs)
		if outputs and not station.hide_outputs:
			inventories.append(outputs)
		inventories.append(Main.singleton.inventory)
		if inputs: cycle(0, 0)
		await get_tree().create_timer(0.3).timeout
		can_craft = true

func get_next_inventory(dir: int) -> Inventory:
	return inventories[(inventories.find(focused_inventory) + dir) % inventories.size()]

func cycle(x: int, y: int):
	if not inputs:
		if crafter: crafter.focus_next_button(y)
		return
	if not Main.singleton.input_detection.using_pad: return
	if focused_slot: focused_slot.mark_for_pad(false)
	if y < 0: focused_inventory = get_next_inventory(-1)
	if y > 0: focused_inventory = get_next_inventory(1)
	var slots = focused_inventory.slots.size() if focused_inventory.slots[0].in_bar else station.slots
	focused_slot_index = ((focused_slot_index + x) + slots) % slots
	focused_slot = focused_inventory.slots[focused_slot_index]
	focused_slot.mark_for_pad(true)
	focused_slot.hover_on()
	move_held_with_pad()

func try_init():
	if inputs and not initialized:
		inputs.create_slots(5)
		inputs.lock()
	if outputs and not initialized:
		outputs.create_slots(5)
		outputs.lock()
	initialized = true

func limit_slots(inv: Inventory, amount: int):
	for i in inv.slots.size():
		inv.slots[i].locked = i >= amount
		inv.slots[i].visible = i < amount

func update_contents():
	if inputs: inputs.clear()
	if outputs: outputs.clear()
	fill(inputs, station.inputs)
	fill(outputs, station.outputs)

func fill(target: Inventory, source: Array[Item]):
	if not target: return
	for i in source.size():
		if source[i]:
			if source[i].data.item_id == Item.Id.Equipment:
				target.slots[i].add_equipment(Main.singleton.bee.tools[source[i].equip])
			else:
				target.slots[i].add_item(source[i].data, source[i].amount, false)

func toggle_outputs(state: bool):
	if outputs: outputs.visible = state
	if output_label: output_label.visible = state
