class_name Preview extends Control

@export var win: GameWindow
@export var craft_button: Button
@export var description: RichTextLabel
@export var materials: RichTextLabel

var equipmment: Equipment

func _ready() -> void:
	win.hide()
	craft_button.pressed.connect(craft)

func close():
	win.hide()

func open():
	win.show()

func show_for(eq: Equipment):
	win.show()
	win.title = eq.name.to_upper()
	description.text = eq.description
	equipmment = eq
	materials.text = Main.singleton.inventory.get_recipe_description(eq.recipe)

func craft():
	Main.singleton.inventory.add_equipment(equipmment)
	Main.shake(10, 0.15)
