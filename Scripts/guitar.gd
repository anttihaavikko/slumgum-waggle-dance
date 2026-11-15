extends Equipment

@export var chord_display: RichTextLabel

var chords = ['C', 'D', 'E', 'F', 'G', 'A', 'B']
var visible_chords = ['']

var played = []

func update(delta: float):
	var dist = roundi(get_global_mouse_position().distance_to(global_position))
	var index = clampi(roundi((dist % 2500 - 200) / 2300.0 * 7), 0, 6)
	chord_display.text = chords[index]
	super.update(delta)
	if Input.is_action_just_pressed("primary"):
		played.append(chords[index])
		if played.size() > 10: played.pop_front()
		check_songs()
	align()

func toggle(state: bool):
	chord_display.visible = state
	visible = state
	played = []

func play(song: String):
	Effects.singleton.pop("[font_size=120][wave amp=50]%s" % [song], global_position + Vector2.UP * 300)

func check(notes: String, song: String):
	var ok = notes.ends_with(song)
	if ok:
		Main.shake(10, 0.2)
		played = []
		play(song)
	return ok

func check_songs():
	var notes = "".join(PackedStringArray(played))
	if check(notes, "BADBAD"):
		Main.singleton.spawn_bird(true)
		return
	if check(notes, "BEEF"):
		for b in Main.singleton.birds: b.leave()
		return
	if check(notes, "CAGE"):
		return
	if check(notes, "DEAD"):
		return
	if check(notes, "DEED"):
		return
	if check(notes, "EGG"):
		return
	if check(notes, "FACE"):
		return
	if check(notes, "GAG"):
		return
	if check(notes, "FEED"):
		return
	if check(notes, "DECAF"):
		return
	if check(notes, "CAFE"):
		Main.singleton.bee.energy_for_life()
		return
	if check(notes, "CABBAGE"):
		return
	if check(notes, "BEAD"):
		return
	if check(notes, "BEDDED"):
		if Main.singleton.time.time > 0.5:
			Main.singleton.time.time = 1
		return
