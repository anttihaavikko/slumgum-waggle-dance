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
var buttons: Array[Button] = []
var built_pieces: Array[BuildPiece] = []

func _ready() -> void:
	for s in starters:
		snap_points.append_array(s.snap_points)
		s.can_break = false
		s.energized = true
	picker.closed.connect(close)
	picker.hide()

	if starters[0] is Station:
		starters[0].title = "Core"
		starters[0].identifier = BuildPiece.Id.Core
		starters[0].description = pieces[BuildPiece.Id.Core].description
		starters[0].setup()

	for i in pieces.size():
		var button = button_prefab.instantiate() as Button
		button.icon = pieces[i].sprite
		button_grid.add_child(button)
		buttons.append(button)
		button.pressed.connect(func(): pick_piece(i))
		button.mouse_entered.connect(func(): show_preview(i))

func load():
	var buildings := Main.singleton.data.buildings
	for i in buildings.size():
		var data = buildings[i]
		var piece = pieces[data[0]].prefab.instantiate() as BuildPiece
		piece.data = pieces[data[0]]
		piece.identifier = data[0] as BuildPiece.Id
		if piece is Station:
			piece.title = pieces[data[0]].title
			piece.description = pieces[data[0]].description
		add_child(piece)
		piece.global_position = Vector2(data[1], data[2])
		piece.rotation = data[3]
		if piece is Station:
			piece.populate(data[4], data[5])
			piece.update_previews()
			if piece.label: piece.label.text = data[6]
			if piece.functionality:
				if piece.functionality is Pot:
					piece.functionality.phase = max(data[7] - 1, 0)
					piece.funtionality.change_phase(true)
		built_pieces.append(piece)
		snap_points.append_array(piece.snap_points)

func hide_undiscovered():
	for i in buttons.size():
		buttons[i].visible = Main.singleton.has_seen_materials(pieces[i].recipe)
		buttons[i].get_node("Marker").visible = not Main.singleton.built.has(i)

func open_menu():
	clear()
	picker.show()
	preview.show()
	hide_undiscovered()

func show_preview(index: int):
	var data = pieces[index] as PieceData
	preview.win.show()
	preview.craft_button.hide()
	preview.win.title = data.title.to_upper()
	preview.description.text = Utils.colorize(data.description, "#FFBA49")
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
			Main.singleton.mark_built(held.identifier)
			Main.singleton.inventory.consume_materials(held.data.recipe)
			snap_points.append_array(held.snap_points)
			prev_angle = held.rotation
			built_pieces.append(held)
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

func remove_snaps_from(target: BuildPiece):
	snap_points = snap_points.filter(func(s): return not target.snap_points.has(s))
