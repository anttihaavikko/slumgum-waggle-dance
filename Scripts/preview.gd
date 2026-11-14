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
	craft_button.show()

func craft():
	var inv = Main.singleton.inventory
	if not inv.has_materials(equipmment.recipe):
		Main.pop("INSUFFICIENT MATERIALS!")
		Main.shake(20, 0.25)
		return
	inv.consume_materials(equipmment.recipe)
	inv.add_equipment(equipmment)
	Main.shake(10, 0.15)
	Main.singleton.mark_crafted(equipmment.identifier)
	Main.singleton.station.crafter.hide_undiscovered()
	show_for(equipmment)
