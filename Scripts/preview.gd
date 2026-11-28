class_name Preview extends Control

@export var win: GameWindow
@export var craft_button: Button
@export var wear_button: Button
@export var description: RichTextLabel
@export var materials: RichTextLabel
@export var materials_title: RichTextLabel

var equipment: Equipment
var selected_item: ItemData
var shown_hat: HatPart

func _ready() -> void:
	win.hide()
	craft_button.pressed.connect(craft)
	wear_button.pressed.connect(wear)
	Main.singleton.register_hoverable(craft_button)

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
	shown_hat = null
	materials.text = Main.singleton.inventory.get_recipe_description(eq.recipe)
	materials.show()
	materials_title.show()
	craft_button.show()
	wear_button.hide()

func show_for_hat(hat: HatPart):
	win.show()
	win.title = hat.title.to_upper()
	description.text = Utils.colorize(hat.description, "#FFBA49")
	shown_hat = hat
	selected_item = null
	equipment = null
	materials.text = Main.singleton.inventory.get_recipe_description(hat.recipe)
	var crafted = Main.singleton.data.created_hats.has(hat.resource_scene_unique_id)
	craft_button.visible = not crafted
	materials_title.visible = not crafted
	materials.visible = not crafted
	wear_button.visible = crafted
	wear_button.text = "TAKE OFF" if Main.singleton.is_wearing(shown_hat) else "WEAR"

func show_for_item(item: ItemData):
	win.show()
	win.title = item.title.to_upper()
	description.text = Utils.colorize(item.description, "#FFBA49")
	selected_item = item
	equipment = null
	shown_hat = null
	materials.text = Main.singleton.inventory.get_recipe_description(item.recipe)
	materials.show()
	materials_title.show()
	craft_button.show()
	wear_button.hide()

func get_recipe() -> Dictionary[Item.Id, int]:
	if selected_item: return selected_item.recipe
	if equipment: return equipment.recipe
	if shown_hat: return shown_hat.recipe
	return {}

func craft():
	var inv = Main.singleton.inventory
	var recipe = get_recipe()
	if not inv.has_materials(recipe):
		Main.pop("INSUFFICIENT MATERIALS!")
		Main.shake(20, 0.25)
		SoundEffects.singleton.add(10, Main.bee_pos())
		return
	inv.consume_materials(recipe)
	if shown_hat:
		Main.singleton.data.created_hats.append(shown_hat.resource_scene_unique_id)
		craft_button.hide()
		wear_button.show()
		materials.hide()
		materials_title.hide()
		Main.singleton.tailor.hide_undiscovered()
		wear()
		return
	if selected_item: inv.add_item(selected_item.item_id, selected_item.recipe_creates)
	else: inv.add_equipment(equipment)
	Main.shake(10, 0.15)
	if not selected_item:
		Main.singleton.mark_crafted(equipment.identifier)
		show_for(equipment)
	else:
		show_for_item(selected_item)
	Main.singleton.station.crafter.hide_undiscovered()

func wear():
	if shown_hat:
		var value = "" if Main.singleton.data.hat_parts[shown_hat.slot] == shown_hat.resource_scene_unique_id else shown_hat.resource_scene_unique_id
		Main.singleton.data.hat_parts[shown_hat.slot] = value
		Main.singleton.update_hat()
		wear_button.text = "TAKE OFF" if Main.singleton.is_wearing(shown_hat) else "WEAR"
