class_name Builder extends Node2D

@export var pieces: Array[PieceData]
@export var cross: Node2D
@export var starters: Array[BuildPiece]
@export var picker: GameWindow
@export var preview: Preview
@export var button_prefab: PackedScene
@export var button_grid: Control

var min_angle := 15

var held: BuildPiece
var held_layer: int
var held_mask: int
var prev_angle := 0.0
var slot := -1
var snap_points: Array[Node2D] = []

func _ready() -> void:
	for s in starters:
		snap_points.append_array(s.snap_points)
	picker.closed.connect(close)
	picker.hide()

	if starters[0] is Station:
		starters[0].title = "Core"
		starters[0].identifier = BuildPiece.Id.Core
		starters[0].setup()

	for i in pieces.size():
		var button = button_prefab.instantiate() as Button
		button.icon = pieces[i].sprite
		button_grid.add_child(button)
		button.pressed.connect(func(): pick_piece(i))
		button.mouse_entered.connect(func(): show_preview(i))

func show_preview(index: int):
	var data = pieces[index] as PieceData
	preview.win.show()
	preview.craft_button.hide()
	preview.win.title = data.title.to_upper()
	preview.description.text = data.description
	preview.materials.text = Main.singleton.inventory.get_recipe_description(data.recipe)

func pick_piece(index: int):
	create(index, true)
	close()

func close():
	if picker.visible:
		picker.hide()
		preview.close()

func _process(_delta) -> void:
	if held:
		held.global_position = get_global_mouse_position()
		held.snap(snap_points)
		cross.visible = not held.can_place()
		if Input.is_action_just_pressed("primary"):
			Main.shake(5, 0.1)
			if not Main.singleton.inventory.has_materials(held.data.recipe):
				Main.pop("INSUFFICIENT MATERIALS!")
				return
			held.try_to_place()
			if cross.visible: return
			Main.singleton.inventory.consume_materials(held.data.recipe)
			snap_points.append_array(held.snap_points)
			prev_angle = held.rotation
			if held.body:
				held.body.collision_layer = held_layer
				held.body.collision_mask = held_mask
			create(slot)
		if held.can_rotate:
			if Input.is_action_just_pressed("wheel_up"):
				held.rotation_degrees += min_angle
			if Input.is_action_just_pressed("wheel_down"):
				held.rotation_degrees -= min_angle
		if Input.is_action_just_pressed("cancel"):
			clear()

	# if Input.is_action_just_pressed("slot_1"): create(0, true)
	# if Input.is_action_just_pressed("slot_2"): create(1, true)

func clear():
	if held:
		slot = -1
		prev_angle = held.rotation
		held.queue_free()
		cross.hide()

func create(s: int, discard: bool = false):
	if s == -1: return
	if discard: clear()
	slot = s
	if not pieces[slot]: return
	held = pieces[slot].prefab.instantiate()
	held.data = pieces[slot]
	held.placed = false
	if not held.can_rotate: prev_angle = 0
	if held and held.body:
		held_layer = held.body.collision_layer
		held_mask = held.body.collision_mask
		held.body.collision_layer = 0
		held.body.collision_mask = 0
		held.identifier = slot as BuildPiece.Id
		if held is Station:
			held.title = pieces[slot].title
			held.description = pieces[slot].description
	add_child(held)
	held.rotation = prev_angle
	held.global_position = get_global_mouse_position()
