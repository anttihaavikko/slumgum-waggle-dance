class_name Queen extends Node2D

@export var queen: Node2D
@export var area: Area2D
@export var bubble: Appearer
@export var message: RichTextLabel
@export var crown: Node2D
@export var glasses: Node2D
@export var glasses_colors: Array[Color]

var off_pos = Vector2.DOWN * 600
var last_appearance := -1
var started := false
var event: QueenEvent
var very_first := true

var event_pool: Array[QueenEvent] = [
	get_hr_event("Instead of (analyzing) and (reacting) to the (bi-annual) employee (feedback questionaire), we've decided to hold it (every quarter). That way you can get your (voice heard) more often and we don't have to actually (read) them."),
	get_hr_event("We at (HR) have received (anonymous complaints) about your (work effort). They (said) that you do (nothing else) than play old (classics) like (Wings) and (V-Wing) all day."),
	QueenEvent.new([
		"We've (decided) to get rid of our (archaic) short-term incentives (bonus program) which you were a part of. The (bonuses) only remain on employees of (job grade 13) and above as they are so (business critical).",
		"There was a lot of (confusion) about the previous (bonus change) announcement from (yesterday). \"Who are these (job grade 13) employees?\", I hear you (ask). That's (just me) of course!",
		"Alongside the (previous bonus changes) from few days ago, I am (personally planning) a new program to (replace) the old one. It's still on (early stages) but I (promise) that it will be (great)!"
	]),
	QueenEvent.new([
		"We're (introducing) a new exciting (hybrid working) model where we are (required) to come back to the (colony) at least (three days) a week. We (firmly believe) this change to (strengthen) our (collaboration) and (innovation).",
		"We've (heard) your (feedback) on the new (hybrid working) model. Mostly (positive) of course, no need to (fact check) this. So we've (decided) to (increase) the (colony) day amount to (four days) a week."
	]),
	QueenEvent.new(
		get_replacement_event("You might have already heard the (news) that our (Queen) has been caught having an (affair) with an (alleged wasp spy). The (board) has decided to (let them go) and we'll (inform) you as soon as we know (more)."),
		get_replacement_skins(true)
	),
	QueenEvent.new(
		get_replacement_event("I am (sad) and (excited) to announce that this will be my (last day) as a (Queen) for this (colony). I will be (moving) to towards new (challenges) but wish everyone here (all the best)."),
		get_replacement_skins()
	)
]

func _ready() -> void:
	show()
	queen.position = off_pos
	area.body_entered.connect(appear)
	area.body_exited.connect(leave)
	# event = event_pool.pop_front()
	event_pool.shuffle()

func get_hr_event(content: String) -> QueenEvent:
	return QueenEvent.new([
		content,
	], [[1, 2, 3, 4].pick_random()])

func get_replacement_skins(immediate: bool = false) -> Array[int]:
	var options = [1, 2, 3, 4]
	options.shuffle()
	var first = options[0]
	var second = options[1]
	return [first, first, first, second, 0] if immediate else [0, first, first, second, 0]

func get_replacement_event(intro) -> Array[String]:
	return [
		intro,
		"Hello, I am (%s) from (HR) and I will be the (acting Queen) until we find a permanent (replacement). The (search) is ongoing and we (already) have a few potential (candidates)." % [get_random_name()],
		"The (search) for the (new Queen) is still going on. One of the (best candidates) had to be (disqualified) because of %s but we still have a couple of (good options)." % [get_random_sack_reason()],
		"Greetings, I am (%s) from (HR). I will be the new (acting acting Queen). The previous (acting queen) was also let go due to %s. Hopefully we will find (someone) to (fill) the position (permanently soon)!" % [get_random_name(), get_random_sack_reason()],
		"I am (%s the %s), the new (Queen)! I will be doing the (rounds) in the (colony) the next few days getting (accustomed) to the (work environments)." % [get_random_name(), RomanNumbers.get_string(randi_range(1, 15))]
	]

func get_random_name() -> String:
	return [
		"Beella",
		"Beessie",
		"Jezebeel",
		"Beethany",
		"Elizabeeth",
		"Beetrix",
		"Beecky",
		"Ambeer",
		"Rebeecca",
		"Beecca",
		"Beeth"
	].pick_random()

func get_random_sack_reason() -> String:
	return [
		"(improper behaviour) around (intern %s)" % get_younglings(),
		"(embezzling honey) from the colony (vault)",
		"trying to (conspire) a (coup)",
		"increased (%s) attacks" % get_random_bird()
	].pick_random()

func get_younglings() -> String:
	return ["brood", "pupae", "larvae"].pick_random()

func get_random_bird() -> String:
	return ["robin", "bee-eater", "shrike", "great tit"].pick_random()

func setup_skin(index: int):
	crown.visible = index == 0
	glasses.visible = index > 0
	glasses.self_modulate = glasses_colors[index - 1]

func appear(_node: Node2D):
	if not Main.singleton.started: return
	if appeared_today(): return
	Main.singleton.bee.heal_if_not_full(1)
	if Main.singleton.time.day == 1:
		await get_tree().create_timer(0.5).timeout
	if event: setup_skin(event.get_skin())
	else: setup_skin(0)
	get_tree().create_tween().tween_property(queen, "position", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BOUNCE)
	last_appearance = Main.singleton.time.day
	await get_tree().create_timer(0.3).timeout
	bubble.appear()
	message.text = Utils.colorize(get_message(), "#FFBA49")

func appeared_today() -> bool:
	return last_appearance == Main.singleton.time.day and not Main.singleton.died

func leave(_node: Node2D):
	await get_tree().create_timer(0.5).timeout
	bubble.disappear()
	await get_tree().create_timer(0.3).timeout
	get_tree().create_tween().tween_property(queen, "position", off_pos, 0.3).set_trans(Tween.TRANS_BOUNCE)

func get_key_values() -> String:
	var values = [
		"transparency",
		"synergy",
		"exceptional customer value",
		"being an industry leader",
		"linear growth",
		"fluid bandwidth",
		"robust portfolio",
		"employee safety",
		"employee happiness",
		"pushing the envelope",
		"%s education" % [get_younglings()]
	]
	values.shuffle()
	return "(%s), (%s) and (%s)" % values.slice(0, 3)

func get_message() -> String:
	# return "(Welcome) to your first (shift newbee)! Fly with [img=330]res://Sprites/wasd.png[/img] or [img=90]res://Sprites/l_stick.png[/img] + [img=100]res://Sprites/rt.png[/img], go find some (flowers) and gather (nectar) from them. Be mindful to not run out of (energy)!"
	if event:
		var msg = event.messages.pop_front()
		event.step += 1
		if event.messages.size() == 0:
			event = null
		return msg

	if Main.singleton.died:
		Main.singleton.died = false
		var intro = [
			"(Welcome) to your first (shift newbee)!"
		].pick_random()
		var fillter = [
			"You've got some big (shoes) to (fill).",
			"You can't do (worse) than the (last guy)."
		].pick_random()
		var ending = [
			"Go do (some work)!",
			"Go find some (flowers) and bring the (nectar) home.",
			"Keep an (eye) on your (energy levels)."
		].pick_random()
		return "%s %s %s" % [intro, fillter, ending]

	var day := Main.singleton.time.day
	var rank := Main.singleton.get_rank_name()
	if day == 1:
		very_first = false
		return "(Welcome) to your first (shift newbee)! Fly with [img=330]res://Sprites/wasd.png[/img] or [img=90]res://Sprites/l_stick.png[/img] + [img=100]res://Sprites/rt.png[/img], go find some (flowers) and gather (nectar) from them. Be mindful to not run out of (energy)!"
	if Main.singleton.crafted.size() > 0 and Main.singleton.built.size() > 3 and not Main.singleton.data.tutorial_over:
		Main.singleton.data.tutorial_over = true
		return "Wow, what a (great worker) you are! Keep it up and you might receive the coveted (employee of the month) title one day."
	if Main.singleton.crafted.size() == 0:
		if Main.singleton.inventory.has(Item.Id.Nectar):
			return "Oh nice, you've been a (busy bee) gathering all that (nectar)! You should try (crafting) a (hammer) from it using the (core)."
		else:
			return "Have you been (slacking) all day? Get your (act together) and go find (flowers) and gather some (nectar)!"
	if Main.singleton.built.size() <= 3:
		return "So you got the hang of (crafting). You should try (building) some (structures) with the (hammer) next. That'll allow you to get even more (materials)."
	if event_pool.size() > 0:
		event = event_pool.pop_front()
	return [
		"Congratulations, you've been promoted to (%s)! I'll be (expecting) you to (deliver) on that (title) too." % [rank],
		"Out (colony bard) has discovered that (music) is a very (powerful) thing. It can (control) many (things) like even our main predators, (birds).",
		"There are (rumors) circulating around that there are actually (two) different (island) neighbouring this one. How many have you (visited) so far?",
		"Our colony (key values) are %s. See the (colony guidebook) for more (information) about them." % [get_key_values()],
		"(Drying rack) is capable of making (wax) from (nectar) and (resin) from (honey). How (versatile) is that?"
	].pick_random()

class QueenEvent:
	var messages: Array[String]
	var skins: Array = []
	var step := 0

	func _init(msgs: Array[String], use_skins: Array = []):
		messages = msgs
		for s in use_skins:
			skins.append(s)

	func get_skin() -> int:
		return skins[step] if step < skins.size() else 0
