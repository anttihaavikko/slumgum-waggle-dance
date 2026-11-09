class_name StationMenu extends Control

@export var inputs: Inventory
@export var outputs: Inventory
@export var win: GameWindow
@export var preview: Preview
@export var description: RichTextLabel

var initialized: bool
var station: Station

func _ready() -> void:
	win.hide()
	win.closed.connect(close)
	if inputs: inputs.added.connect(inventory_changed)
	if outputs: outputs.added.connect(inventory_changed)

func _process(_delta) -> void:
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
	win.hide()
	Main.singleton.inventory.other = null
	Main.singleton.station = null
	if station and inputs: station.inputs = inputs.get_contents()
	if station and outputs: station.outputs = outputs.get_contents()
	if station: station.try_convert()
	if Main.singleton.held:
		Main.singleton.held.drop()
		Main.singleton.held.hide()

func open(source: Station):
	if Main.singleton.station:
		Main.singleton.station.close()
	station = source
	Main.singleton.station = self
	Main.singleton.inventory.other = inputs
	if inputs: inputs.other = Main.singleton.inventory
	if outputs: outputs.other = Main.singleton.inventory
	win.show()
	if preview: preview.open()

	if inputs and not initialized: inputs.create_slots(5)
	if outputs and not initialized: outputs.create_slots(5)
	initialized = true

	update_contents()
	station.try_convert()

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
				target.slots[i].add_item(source[i].data, source[i].amount)
