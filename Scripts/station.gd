class_name Station extends BuildPiece

@export var title: String
@export var button: Button
@export var center: Node2D
@export var converts: Array[Converter]

var inputs: Array[Item] = []
var outputs: Array[Item] = []

var menu: StationMenu
var cooldown := 0.0
var working := false

func _ready() -> void:
	# sprite.modulate = Color.RED
	menu = Main.singleton.stations[identifier]
	button.pressed.connect(open)
	button.mouse_entered.connect(announce)

func _process(delta) -> void:
	cooldown -= delta

func announce():
	if cooldown > 0: return
	if Main.singleton.builder.held: return
	Effects.singleton.pop(title.to_upper(), center.global_position + Vector2.UP * 100)
	cooldown = 0.5

func open():
	if not Main.singleton.bee.can_open(): return
	if Main.singleton.builder.held: return
	if not menu: return
	if menu.is_open():
		menu.close()
		return
	menu.open(self)
	menu.win.title = title.to_upper()

func has_input_item(id: Item.Id) -> bool:
	return inputs.any(func(i: Item): return i and i.data and i.data.item_id == id)

func consume(id: Item.Id):
	var item = inputs.find_custom(func(i: Item): return i and i.data.item_id == id and i.amount > 0)
	if item >= 0:
		inputs[item].amount -= 1
		if inputs[item].amount == 0:
			inputs[item] = null

func pull_contents():
	if menu.inputs: inputs = menu.inputs.get_contents()
	if menu.outputs: outputs = menu.outputs.get_contents()

func add(id: Item.Id):
	var item = outputs.find_custom(func(i: Item): return i and i.data.item_id == id and i.amount < 20)
	if item >= 0: outputs[item].amount += 1
	else:
		outputs[outputs.find(null)] = Item.new(Main.get_item_data(id))

func try_convert():
	if converts.size() == 0: return
	if working: return
	working = true
	for recipe in converts:
		if has_input_item(recipe.input[0].item):
			await get_tree().create_timer(5).timeout
			var looking = menu and menu.is_open() and menu.station == self
			if looking:
				pull_contents()
			if has_input_item(recipe.input[0].item):
				consume(recipe.input[0].item)
				add(recipe.output[0].item)
				if looking:
					menu.update_contents()
				working = false
				try_convert()
	working = false
