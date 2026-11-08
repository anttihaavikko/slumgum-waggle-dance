extends Node2D

@export var door: Door
@export var area: Area2D
@export var button: Node2D

var normal: Vector2
var pushed: Vector2

func _ready() -> void:
	normal = button.position
	pushed = button.position + Vector2.DOWN * 40
	area.body_entered.connect(open)
	area.body_exited.connect(close)

func open(_node: Node2D):
	if door: door.open()
	get_tree().create_tween().tween_property(button, "position", pushed, 0.3).set_trans(Tween.TRANS_QUAD)

func close(_node: Node2D):
	get_tree().create_tween().tween_property(button, "position", normal, 0.3).set_trans(Tween.TRANS_QUAD)
	await get_tree().create_timer(3).timeout
	if door: door.close()
