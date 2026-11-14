extends Node2D

@export var queen: Node2D
@export var area: Area2D

var off_pos = Vector2.DOWN * 600
var last_appearance := -1

func _ready() -> void:
	queen.position = off_pos
	area.body_entered.connect(appear)
	area.body_exited.connect(leave)

func appear(_node: Node2D):
	if appeared_today(): return
	if Main.singleton.time.day == 1:
		await get_tree().create_timer(0.5).timeout
	get_tree().create_tween().tween_property(queen, "position", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BOUNCE)
	last_appearance = Main.singleton.time.day

func appeared_today() -> bool:
	return last_appearance == Main.singleton.time.day

func leave(_node: Node2D):
	await get_tree().create_timer(0.5).timeout
	get_tree().create_tween().tween_property(queen, "position", off_pos, 0.3).set_trans(Tween.TRANS_BOUNCE)
