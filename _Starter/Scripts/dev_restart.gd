class_name DevRestart extends Node

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_R) and OS.is_debug_build():
			if Blinders.singleton:
				Blinders.singleton.close()
				await Blinders.singleton.closed
			get_tree().reload_current_scene()
