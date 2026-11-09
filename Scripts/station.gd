class_name Station extends BuildPiece

@export var title: String
@export var button: Button
@export var center: Node2D
@export var converts: Array[Converter]
@export var input_preview: Array[Sprite2D]
@export var output_preview: Array[Sprite2D]

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
	update_previews()

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
	# if menu.description: menu.description.text = "foo bar"

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
	update_previews()

func update_previews():
	update_preview(input_preview, inputs)
	update_preview(output_preview, outputs)

func update_preview(previews: Array[Sprite2D], source: Array[Item]):
	for p in previews:
		p.hide()
	for i in source.size():
		var item = source[i]
		if item and item.amount > 0 and i < previews.size():
			previews[i].show()
			previews[i].texture = item.data.sprite
			previews[i].self_modulate = item.data.color

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
				update_previews()
				try_convert()
	working = false
