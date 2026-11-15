class_name Crafter extends Control

@export var recipes: Array[Equipment.Id]
@export var item_recipes: Array[Item.Id]
@export var button_prefab: PackedScene
@export var preview: Preview
@export var creates_items := false

var buttons: Array[Button] = []
var index := 0

func _ready() -> void:
	for i in recipes.size():
		var eq = Main.singleton.bee.tools[recipes[i]]
		var button = button_prefab.instantiate() as Button
		button.toggle_mode = true
		buttons.append(button)
		button.text = eq.name
		button.icon = Main.singleton.new_marker
		button.pressed.connect(func(): press(eq, button, i))
		add_child(button)
	for i in item_recipes.size():
		var item = Main.singleton.item_db.items[item_recipes[i]]
		var button = button_prefab.instantiate() as Button
		button.toggle_mode = true
		buttons.append(button)
		button.text = item.title
		button.icon = Main.singleton.new_marker
		button.pressed.connect(func(): press_for_item(item, button, i))
		add_child(button)
	open()

func hide_undiscovered():
	if creates_items: return
	for i in buttons.size():
		buttons[i].visible = Main.singleton.has_seen_materials(Main.singleton.bee.tools[recipes[i]].recipe)
		buttons[i].icon = Main.singleton.new_marker if not Main.singleton.crafted.has(recipes[i]) else null

func open():
	if creates_items:
		press_for_item(Main.singleton.item_db.items[item_recipes[index]], buttons[index], index)
		return
	hide_undiscovered()
	press(Main.singleton.bee.tools[recipes[index]], buttons[index], index)

func press(eq: Equipment, button: Button, idx: int):
	index = idx
	deselect_all(button)
	preview.show_for(eq)

func press_for_item(item: ItemData, button: Button, idx: int):
	index = idx
	deselect_all(button)
	preview.show_for_item(item)

func deselect_all(button: Button = null):
	for b in buttons:
		b.set_pressed_no_signal(b == button)
