class_name StationMenu extends Control

@export var inputs: Inventory
@export var outputs: Inventory
@export var win: GameWindow
@export var preview: Preview

var initialized: bool
var station: Station

func _ready() -> void:
	win.hide()
	win.closed.connect(close)

func _process(_delta) -> void:
	if visible and Input.is_action_just_pressed("cancel"):
		close()

func is_open() -> bool:
	return win.visible

func close():
	if preview: preview.close()
	win.hide()
	Main.singleton.inventory.other = null
	Main.singleton.station = null
	if station and inputs: station.inputs = inputs.get_contents()
	if station and outputs: station.outputs = outputs.get_contents()
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
	win.show()
	if preview: preview.open()

	if inputs and not initialized: inputs.create_slots(3)
	initialized = true

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
