class_name Cup extends Node2D

@export var station: Station
@export var stinger: Node2D

func _ready() -> void:
	var item = Item.new(Main.singleton.item_db.items[Item.Id.Equipment])
	item.equip = Equipment.Id.Stinger
	station.outputs.append(item)
	station.description = Utils.colorize("A (mighty stinger) of a (stillborn queen). Wield it with (grace)!\n\nYou can place (other eggs) in the (inputs slots) to power up the (blade).", "#FFBA49")
	station.updated.connect(check)

func check():
	if station.outputs.size() == 0 or not station.outputs[0] or (station.inputs and station.inputs[0]):
		stinger.hide()
