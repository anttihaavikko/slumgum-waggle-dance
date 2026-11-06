class_name StationMenu extends Control

@export var inputs: Inventory
@export var outputs: Inventory

var initialized: bool
var station: Station

func _ready() -> void:
	hide()

func _process(_delta) -> void:
	if visible and Input.is_action_just_pressed("cancel"):
		close()

func close():
	hide()
	Main.singleton.inventory.other = null
	Main.singleton.station = null
	if inputs: station.inputs = inputs.get_contents()
	if outputs: station.outputs = outputs.get_contents()

func open(source: Station):
	if Main.singleton.station:
		Main.singleton.station.close()
	station = source
	Main.singleton.station = self
	Main.singleton.inventory.other = inputs
	if inputs: inputs.other = Main.singleton.inventory
	show()

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
			target.slots[i].add_item(source[i].data, source[i].amount)
