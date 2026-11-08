extends Control

@export var button_prefab: PackedScene
@export var preview: Preview

var buttons: Array[Button] = []

func _ready() -> void:
	for eq in Main.singleton.bee.tools:
		var button = button_prefab.instantiate() as Button
		button.toggle_mode = true
		buttons.append(button)
		button.text = eq.name
		button.pressed.connect(func(): press(eq, button))
		add_child(button)
	press(Main.singleton.bee.tools[0], buttons[0])

func press(eq: Equipment, button: Button):
	deselect_all(button)
	preview.show_for(eq)

func deselect_all(button: Button = null):
	for b in buttons:
		b.set_pressed_no_signal(b == button)
