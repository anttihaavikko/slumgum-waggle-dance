class_name Station extends BuildPiece

@export var button: Button
@export var center: Node2D
@export var converts: Array[Converter]
@export var input_preview: Array[Sprite2D]
@export var output_preview: Array[Sprite2D]
@export var crafting_animation: AnimationPlayer
@export var sleeper: Node2D
@export var slots := 1
@export var hide_outputs := false
@export var interactable := true

var title: String
var description: String

var inputs: Array[Item] = []
var outputs: Array[Item] = []

var menu: StationMenu
var cooldown := 0.0
var working := false

signal updated

func _ready() -> void:
	# sprite.modulate = Color.RED
	button.pressed.connect(open)
	button.mouse_entered.connect(announce)
	button.mouse_exited.connect(func(): Main.singleton.hovering = false)
	update_previews()
	if crafting_animation: crafting_animation.stop()
	setup()

func setup():
	menu = Main.singleton.stations[identifier]

func _process(delta) -> void:
	cooldown -= delta

func announce(include_pad_help := false):
	if cooldown > 0: return
	if Main.singleton.builder.held: return
	Effects.singleton.pop("[wave]%s" % [title.to_upper()], center.global_position + Vector2.UP * 100)
	cooldown = 0.5
	Main.singleton.hovering = true
	if include_pad_help:
		await get_tree().create_timer(0.15).timeout
		Effects.singleton.pop("[font_size=60][wave]PRESS A TO INTERACT", center.global_position)

func open():
	if not placed: return
	if not Main.singleton.bee.can_open(): return
	if global_position.distance_to(Main.singleton.bee.body.global_position) > 750:
		Main.pop("TOO FAR!")
		return
	Main.singleton.time.sleeper = sleeper
	if Main.singleton.builder.held: return
	if not menu: return
	if menu.is_open():
		menu.close()
		return
	menu.open(self)
	menu.win.title = title.to_upper()
	if menu.description:
		menu.description.text = Utils.colorize(description, "#FFBA49")
	menu.toggle_outputs(not hide_outputs)

func has_input_item(id: Item.Id) -> bool:
	return inputs.any(func(i: Item): return i and i.data and i.data.item_id == id)

func consume(id: Item.Id):
	var item = inputs.find_custom(func(i: Item): return i and i.data.item_id == id and i.amount > 0)
	if item >= 0:
		inputs[item].amount -= 1
		if inputs[item].amount == 0:
			inputs[item] = null

func drop_items():
	if inputs: drop_items_from(inputs)
	if outputs: drop_items_from(outputs)

func drop_items_from(arr: Array[Item]):
	for i in arr:
		if not i: continue
		Main.drop_at(i, null, center.global_position)

func pull_contents():
	if menu.inputs: inputs = menu.inputs.get_contents()
	if menu.outputs: outputs = menu.outputs.get_contents()
	update_previews()

func update_previews():
	update_preview(input_preview, inputs, true)
	update_preview(output_preview, outputs, false)
	updated.emit()
	if functionality is Totem:
		functionality.sprite.hide()
		if inputs.size() > 0 and inputs[0]:
			functionality.setup(inputs[0].data.item_id)

func accepts(id: Item.Id) -> bool:
	if converts.size() == 0: return true
	for recipe in converts:
		for part in recipe.input:
			if part.item == id:
				return true
	return false

func update_preview(previews: Array[Sprite2D], source: Array[Item], filters: bool):
	for p in previews:
		p.hide()
	var pi = 0
	for i in source.size():
		var item = source[i]
		if item and item.amount > 0 and pi < previews.size():
			if not functionality and filters and not accepts(item.data.item_id): continue
			previews[pi].show()
			previews[pi].texture = item.data.sprite
			previews[pi].self_modulate = item.data.color
			pi += 1

func add(id: Item.Id, amt: int = 1):
	var item = outputs.find_custom(func(i: Item): return i and i.data.item_id == id and i.amount < 20)
	if item >= 0:
		outputs[item].amount += amt
	else:
		outputs[outputs.find(null)] = Item.new(Main.get_item_data(id), amt)

func try_convert():
	if converts.size() == 0: return
	if working: return
	working = true
	for recipe in converts:
		if has_input_item(recipe.input[0].item):
			if crafting_animation: crafting_animation.play()
			await get_tree().create_timer(5).timeout
			var looking = menu and menu.is_open() and menu.station == self
			if looking:
				pull_contents()
			if has_input_item(recipe.input[0].item):
				consume(recipe.input[0].item)
				add(recipe.output[0].item, recipe.output[0].amount)
				if looking:
					menu.update_contents()
				working = false
				update_previews()
				stop_animation()
				try_convert()
			else:
				stop_animation()
	working = false

func stop_animation():
	if crafting_animation:
		crafting_animation.stop()

func get_inputs_for_save() -> Array:
	return get_items_for_save(inputs)

func get_outputs_for_save() -> Array:
	return get_items_for_save(outputs)

func get_items_for_save(arr: Array[Item]) -> Array:
	var val = []
	val.resize(arr.size())
	for i in arr.size():
		if not arr[i]: continue
		val[i] = [arr[i].data.item_id, arr[i].amount, arr[i].equip]
	return val

func populate(inp: Array, out: Array):
	inputs = get_populated(inp)
	outputs = get_populated(out)

func get_populated(arr: Array) -> Array[Item]:
	var items: Array[Item] = []
	var db := Main.singleton.item_db
	items.resize(5)
	for i in arr.size():
		var dat = arr[i]
		if not dat: continue
		items[i] = Item.new(db.items[dat[0]], dat[1])
		items[i].equip = dat[2]
	return items

func get_extras() -> Array:
	if functionality:
		if functionality is Pot:
			return [functionality.phase, functionality.prefab_index]
	return []
