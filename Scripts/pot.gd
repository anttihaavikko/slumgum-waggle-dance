class_name Pot extends Node2D

@export var flower_prefabs: Array[PackedScene]
@export var station: Station
@export var phases: Array[Node2D]

var phase := 0
var seeds := [Item.Id.Seed, Item.Id.GoldSeed, Item.Id.PureSeed]
var prefab: PackedScene

func _ready() -> void:
	station.updated.connect(station_updated)

func is_seed(id: Item.Id):
	return seeds.has(id)

func station_updated():
	if phase > 0: return
	if station.inputs.size() > 0:
		if station.inputs[0] and is_seed(station.inputs[0].data.item_id):
			phases[0].modulate = station.inputs[0].data.color
			prefab = flower_prefabs[seeds.find(station.inputs[0].data.item_id)]
			station.consume(station.inputs[0].data.item_id)
			change_phase(true)
			if station.menu:
				station.menu.update_contents()

func create_nectar() -> Item:
	return Item.new(Main.singleton.item_db.items[Item.Id.Nectar])

func update_menu():
	if station.menu and station.menu.visible:
		station.menu.update_contents()

func change_phase(starting := false):
	if phase == 4:
		if station.menu and station.menu.visible:
			station.pull_contents()
		if not station.outputs[0]:
			station.outputs[0] = create_nectar()
			update_menu()
			return
		if station.outputs.size() == 0:
			station.outputs.append(create_nectar())
			update_menu()
			return
		if station.outputs[0].data.item_id == Item.Id.Nectar and station.outputs[0].amount < 20:
			station.outputs[0].amount += 1
			update_menu()
		return
	if not starting and phase == 0: return
	if phase > 0: phases[phase - 1].hide()
	phase += 1
	if phase == 4:
		var flower = prefab.instantiate() as Flower
		flower.breakable.drop_multiplier = 2
		add_child(flower)
		flower.breakable.broke.connect(reset)
		return
	phases[phase - 1].show()

func reset():
	phase = 0
	station_updated()
