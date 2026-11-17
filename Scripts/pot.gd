class_name Pot extends Node2D

@export var flower_prefabs: Array[PackedScene]
@export var station: Station
@export var phases: Array[Node2D]

var phase := 0

func _ready() -> void:
	station.updated.connect(station_updated)

func station_updated():
	if phase > 0: return
	if station.inputs.size() > 0:
		if station.inputs[0].data.item_id == Item.Id.Seed:
			station.consume(station.inputs[0].data.item_id)
			phases[0].modulate = station.inputs[0].data.color
			change_phase(true)
			if station.menu:
				station.menu.update_contents()

func change_phase(starting := false):
	if not starting and phase == 0 or phase == 4: return
	if phase > 0: phases[phase - 1].hide()
	phase += 1
	if phase == 4:
		var flower = flower_prefabs[0].instantiate() as Flower
		flower.breakable.drop_multiplier = 2
		add_child(flower)
		flower.breakable.broke.connect(reset)
		return
	phases[phase - 1].show()

func reset():
	phase = 0
	station_updated()
