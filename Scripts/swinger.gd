class_name Swinger extends Node2D

func swing(dir: float = 1.0):
	var mod = -1 if get_global_mouse_position().x > global_position.x else 1
	SoundEffects.singleton.add(35, global_position)
	get_tree().create_tween().tween_property(self, "rotation_degrees", 180 * dir * mod, 0.1).set_trans(Tween.TRANS_BOUNCE)
	await get_tree().create_timer(0.12).timeout
	get_tree().create_tween().tween_property(self, "rotation_degrees", 0, 0.2).set_trans(Tween.TRANS_QUAD)
