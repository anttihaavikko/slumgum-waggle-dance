class_name Builder extends Node2D

@export var pieces: Array[PackedScene]

var min_angle := 15

var held: Node2D
var held_layer: int
var held_mask: int
var prev_angle := 0.0
var slot := 0

func _ready() -> void:
	create(0)

func _process(_delta) -> void:
	if held:
		held.global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("place"):
			prev_angle = held.rotation
			held.collision_layer = held_layer
			held.collision_mask = held_mask
			create(slot)
		if Input.is_action_just_pressed("rotate_right"):
			held.rotation_degrees += min_angle
		if Input.is_action_just_pressed("rotate_left"):
			held.rotation_degrees -= min_angle

	if Input.is_action_just_pressed("slot_1"): create(0, true)
	if Input.is_action_just_pressed("slot_2"): create(1, true)


func create(s: int, discard: bool = false):
	if discard and held:
		prev_angle = held.rotation
		held.queue_free()
	slot = s
	held = pieces[slot].instantiate()
	if held is StaticBody2D:
		held_layer = held.collision_layer
		held_mask = held.collision_mask
		held.collision_layer = 0
		held.collision_mask = 0
	add_child(held)
	held.rotation = prev_angle
	held.global_position = get_global_mouse_position()
