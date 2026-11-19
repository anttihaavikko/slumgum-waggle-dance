class_name Preview extends Control

@export var win: GameWindow
@export var craft_button: Button
@export var description: RichTextLabel
@export var materials: RichTextLabel

var equipment: Equipment
var selected_item: ItemData

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
	description.text = Utils.colorize(eq.description, "#FFBA49")
	equipment = eq
	selected_item = null
	materials.text = Main.singleton.inventory.get_recipe_description(eq.recipe)
	craft_button.show()

func show_for_item(item: ItemData):
	win.show()
	win.title = item.title.to_upper()
	description.text = Utils.colorize(item.description, "#FFBA49")
	selected_item = item
	equipment = null
	materials.text = Main.singleton.inventory.get_recipe_description(item.recipe)
	craft_button.show()

func craft():
	var inv = Main.singleton.inventory
	var recipe = selected_item.recipe if selected_item else equipment.recipe
	if not inv.has_materials(recipe):
		Main.pop("INSUFFICIENT MATERIALS!")
		Main.shake(20, 0.25)
		return
	inv.consume_materials(recipe)
	if selected_item: inv.add_item(selected_item.item_id, selected_item.recipe_creates)
	else: inv.add_equipment(equipment)
	Main.shake(10, 0.15)
	if not selected_item:
		Main.singleton.mark_crafted(equipment.identifier)
		show_for(equipment)
	else:
		show_for_item(selected_item)
	Main.singleton.station.crafter.hide_undiscovered()
