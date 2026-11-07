class_name Builder extends Node2D

@export var pieces: Array[PackedScene]
@export var cross: Node2D

var min_angle := 15

var held: BuildPiece
var held_layer: int
var held_mask: int
var prev_angle := 0.0
var slot := 0

# func _ready() -> void:
# 	create(0)

func _process(_delta) -> void:
	if held:
		held.global_position = get_global_mouse_position()
		cross.visible = not held.can_place()
		if Input.is_action_just_pressed("primary") and not cross.visible:
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
		prev_angle = held.rotation
		held.queue_free()
		cross.hide()

func create(s: int, discard: bool = false):
	if discard: clear()
	slot = s
	held = pieces[slot].instantiate()
	if not held.can_rotate: prev_angle = 0
	if held and held.body:
		held_layer = held.body.collision_layer
		held_mask = held.body.collision_mask
		held.body.collision_layer = 0
		held.body.collision_mask = 0
	add_child(held)
	held.rotation = prev_angle
	held.global_position = get_global_mouse_position()
