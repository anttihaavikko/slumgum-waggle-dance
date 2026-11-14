extends Node2D

@export var queen: Node2D
@export var area: Area2D
@export var bubble: Appearer
@export var message: RichTextLabel

var off_pos = Vector2.DOWN * 600
var last_appearance := -1
var started := false
var event: QueenEvent

var event_pool: Array[QueenEvent] = [
	QueenEvent.new([
		"First of event",
		"Second of event"
	]),
	QueenEvent.new([
		"Solo event"
	])
]

func _ready() -> void:
	queen.position = off_pos
	area.body_entered.connect(appear)
	area.body_exited.connect(leave)
	event_pool.shuffle()

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
	if event:
		var msg = event.messages.pop_front()
		if event.messages.size() == 0:
			event = null
		return msg

	var day := Main.singleton.time.day
	# queued.append_array([
	# 	"First",
	# 	"Second"
	# ])
	if day == 1:
		return "Welcome to your first (shift newbee)! Fly around with (WASD), go find some (flowers) and gather (nectar) from them.\n\nBe mindful to not run out of (energy)!"
	if Main.singleton.crafted.size() > 0 and Main.singleton.built.size() > 3 and not started:
		started = true
		return "Wow, what a (great worker) you are! Keep it up and you might receive the coveted (employee of the month) title one day."
	if Main.singleton.crafted.size() == 0:
		if Main.singleton.inventory.has(Item.Id.Nectar):
			return "Oh nice, you've been a (busy bee) gathering all that (nectar)! You should try (crafting) a (hammer) from it using the (core)."
		else:
			return "Have you been (slacing) all day? Get your (act together) and go find (flowers) and gather some (nectar)!"
	if Main.singleton.built.size() <= 3:
		return "So you got the hang of (crafting). You should try (building) some (structures) with the (hammer) next. That'll allow you to get even more (materials)."
	if event_pool.size() > 0:
		event = event_pool.pop_front()
	return [
		"Lorem ipsum dolor sit amet."
	].pick_random()

class QueenEvent:
	var messages: Array[String]

	func _init(msgs: Array[String]):
		messages = msgs
