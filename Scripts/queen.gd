extends Node2D

@export var queen: Node2D
@export var area: Area2D
@export var bubble: Appearer
@export var message: RichTextLabel

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
	await get_tree().create_timer(0.3).timeout
	bubble.appear()
	message.text = Utils.colorize(get_message(), "#FFBA49")

func appeared_today() -> bool:
	return last_appearance == Main.singleton.time.day

func leave(_node: Node2D):
	await get_tree().create_timer(0.5).timeout
	bubble.disappear()
	await get_tree().create_timer(0.3).timeout
	get_tree().create_tween().tween_property(queen, "position", off_pos, 0.3).set_trans(Tween.TRANS_BOUNCE)

func get_message() -> String:
	var day := Main.singleton.time.day
	if day == 1:
		return "Welcome to your first (shift newbee)! Fly around with (WASD), go find some (flowers) and gather (nectar) from them.\n\nBe mindful to not run out of (energy)!"

	return [
		"Lorem ipsum dolor sit amet."
	].pick_random()
