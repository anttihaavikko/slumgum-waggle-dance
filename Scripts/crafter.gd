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
		button.pressed.connect(func(): press(eq, button, i))
		add_child(button)
	open()

func open():
	press(Main.singleton.bee.tools[recipes[index]], buttons[index], index)

func press(eq: Equipment, button: Button, idx: int):
	index = idx
	deselect_all(button)
	preview.show_for(eq)

func deselect_all(button: Button = null):
	for b in buttons:
		b.set_pressed_no_signal(b == button)
