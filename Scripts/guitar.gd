extends Equipment

@export var chord_display: RichTextLabel

var chords = ['C', 'D', 'E', 'F', 'G', 'A', 'B']
var visible_chords = ['']

var played = []

func update(delta: float):
	var dist = max(200, roundi(get_global_mouse_position().distance_to(global_position)))
	var index = max(roundi(dist % 2000 / 2000.0 * 7) - 1, 0)
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

func check_songs():
	var notes = "".join(PackedStringArray(played))
	if notes.ends_with("BADBAD"):
		Main.singleton.spawn_bird()
		played = []
	if notes.ends_with("BEEF"):
		played = []
	if notes.ends_with("CAGE"):
		played = []
	if notes.ends_with("DEAD"):
		played = []
	if notes.ends_with("DEED"):
		played = []
	if notes.ends_with("EGG"):
		played = []
	if notes.ends_with("FACE"):
		played = []
	if notes.ends_with("GAG"):
		played = []
	if notes.ends_with("FEED"):
		played = []
	if notes.ends_with("DECAF"):
		played = []
	if notes.ends_with("CAFE"):
		played = []
	if notes.ends_with("CABBAGE"):
		played = []
	if notes.ends_with("BEAD"):
		played = []
