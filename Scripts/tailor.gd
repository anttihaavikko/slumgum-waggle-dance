class_name Tailor extends Control

@export var recipes: Array[HatPart]
@export var button_prefab: PackedScene
@export var preview: Preview
@export var scroller: ScrollContainer

var buttons: Array[Button] = []
var index := 0

func _ready() -> void:
	for i in recipes.size():
		var button = button_prefab.instantiate() as Button
		button.toggle_mode = true
		buttons.append(button)
		button.text = recipes[i].title
		button.icon = Main.singleton.new_marker
		button.toggled.connect(func(_state): press(recipes[i], button, i))
		Main.singleton.register_hoverable(button)
		add_child(button)
	open()

func hide_undiscovered():
	for i in buttons.size():
		buttons[i].visible = Main.singleton.has_seen_materials(recipes[i].recipe)
		buttons[i].icon = Main.singleton.new_marker if not Main.singleton.data.created_hats.has(recipes[i].resource_scene_unique_id) else null

func open():
	hide_undiscovered()
	press(recipes[index], buttons[index], index)

func focus_next_button(dir: int):
	buttons[index].button_pressed = false
	var visible_buttons := buttons.filter(func(b): return b.visible)
	index = (visible_buttons.find(buttons[index]) + dir) % visible_buttons.size()
	visible_buttons[index].button_pressed = true
	if abs(dir) > 0: SoundEffects.singleton.add(46, global_position, 0.5)
	scroller.ensure_control_visible(visible_buttons[index])


func press(eq: HatPart, button: Button, idx: int):
	index = idx
	deselect_all(button)
	preview.show_for_hat(eq)

func press_for_item(item: ItemData, button: Button, idx: int):
	index = idx
	deselect_all(button)
	preview.show_for_item(item)

func deselect_all(button: Button = null):
	for b in buttons:
		b.set_pressed_no_signal(b == button)
