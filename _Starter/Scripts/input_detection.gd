class_name InputDetection extends Node

var using_pad := false
var last_dir := Vector2.ZERO

func get_position(node: Node2D, distance: float = 100) -> Vector2:
	var x = Input.get_axis("look_left", "look_right")
	var y = Input.get_axis("look_up", "look_down")
	var dir = Vector2(x, y)
	if dir.length() > 0.1: last_dir = dir
	return node.global_position + last_dir * distance if using_pad else node.get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		using_pad = false
	if event is InputEventJoypadButton:
		using_pad = true
	if event is InputEventJoypadMotion and abs(event.axis_value) > 0.5:
		using_pad = true
