class_name Crafter extends Control

@export var recipes: Array[Equipment.Id]
@export var button_prefab: PackedScene
@export var preview: Preview

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
	open()

func hide_undiscovered():
	for i in buttons.size():
		buttons[i].visible = Main.singleton.has_seen_materials(Main.singleton.bee.tools[recipes[i]].recipe)
		buttons[i].icon = Main.singleton.new_marker if not Main.singleton.crafted.has(recipes[i]) else null

func open():
	hide_undiscovered()
	press(Main.singleton.bee.tools[recipes[index]], buttons[index], index)

func press(eq: Equipment, button: Button, idx: int):
	index = idx
	deselect_all(button)
	preview.show_for(eq)

func deselect_all(button: Button = null):
	for b in buttons:
		b.set_pressed_no_signal(b == button)
