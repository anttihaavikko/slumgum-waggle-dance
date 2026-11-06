extends Control

@export var button_prefab: PackedScene

func _ready() -> void:
	for eq in Main.singleton.bee.tools:
		var button = button_prefab.instantiate() as Button
		button.text = eq.name
		button.pressed.connect(func(): press(eq))
		add_child(button)

func press(eq: Equipment):
	Main.singleton.inventory.add_equipment(eq)
