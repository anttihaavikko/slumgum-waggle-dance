extends Node2D

@export var input_detection: InputDetection

func _process(_delta) -> void:
	global_position = input_detection.get_mouse_position(self) if input_detection else get_global_mouse_position()
