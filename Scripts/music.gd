extends Node

@export var day: AudioStreamPlayer
@export var night: AudioStreamPlayer

func _ready() -> void:
	pass

func set_volumes(val: float):
	day.volume_linear = val * 0.6
	night.volume_linear = (1 - val) * 0.5
