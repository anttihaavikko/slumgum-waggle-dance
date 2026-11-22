extends Node

@export var day: AudioStreamPlayer
@export var night: AudioStreamPlayer
@export var bird: AudioStreamPlayer
@export var normal: AudioStreamPlayer

func bird_attack(state: bool):
	get_tree().create_tween().tween_property(normal, "volume_linear", 0 if state else 1, 1).set_trans(Tween.TRANS_QUAD)
	if state: await get_tree().create_timer(0.5).timeout
	bird.playing = state
	AudioServer.set_bus_effect_enabled(1, 0, not state)

func set_volumes(val: float):
	day.volume_linear = val * 0.6
	night.volume_linear = (1 - val) * 0.5
