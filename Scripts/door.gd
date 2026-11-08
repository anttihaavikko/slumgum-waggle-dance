class_name Door extends Node2D

var open_pos: Vector2
var closed_pos: Vector2

func _ready() -> void:
	closed_pos = position
	open_pos = position + Vector2.DOWN * 700

func open():
	get_tree().create_tween().tween_property(self, "position", open_pos, 0.3).set_trans(Tween.TRANS_QUAD)

func close():
	get_tree().create_tween().tween_property(self, "position", closed_pos, 0.5).set_trans(Tween.TRANS_QUAD)
