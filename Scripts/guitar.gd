extends Equipment

@export var chord_display: RichTextLabel
@export var mouse_scale: Node2D
@export var pad_scale: Node2D

var chords = ['D', 'E', 'F', 'G', 'A', 'B', 'C']
var visible_chords = ['D', 'Em', 'F#m', 'G', 'A', 'Bm', 'C#m']

var played = []
var timer = Timer.new()

func _ready() -> void:
	add_child(timer)
	timer.timeout.connect(restart_music)

func update(delta: float):
	var pad := Main.singleton.input_detection.using_pad
	mouse_scale.visible = not pad
	pad_scale.visible = pad
	if pad: pad_scale.rotation = -Main.singleton.bee.body.rotation
	var index = get_note()
	chord_display.text = visible_chords[index]
	super.update(delta)
	if Input.is_action_just_pressed("primary") or Input.is_action_just_pressed("alt"):
		Music.mute()
		timer.stop()
		timer.start(2.5)
		played.append(chords[index])
		var offset = 28 if Input.is_action_just_pressed("alt") else 21
		SoundEffects.singleton.add(index + offset, global_position, 1, 0)
		if played.size() > 10: played.pop_front()

		check_songs()
	align()

func get_note() -> int:
	var pad := Main.singleton.input_detection.using_pad
	if pad:
		var dir := pad_scale.to_local(Main.singleton.input_detection.get_mouse_direction(pad_scale))
		chord_display.global_position = pad_scale.global_position + dir.normalized() * 700
		return floori((dir.angle() + PI) / TAU * 7)
	else:
		var dist = roundi(get_global_mouse_position().distance_to(global_position))
		return clampi(roundi((dist % 2300 - 200) / 2100.0 * 7), 0, 6)

func restart_music():
	Music.resume()

func toggle(state: bool):
	chord_display.visible = state
	if not state: pad_scale.hide()
	if state: get_note()
	visible = state
	played = []

func play(song: String):
	timer.stop()
	restart_music()
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
		Main.singleton.open_doors(Hut.DoorType.Music)
		return
	if check(notes, "DEAD"):
		Main.singleton.death_save = true
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
		Main.singleton.bee.heal(1)
		return
	if check(notes, "DECAF"):
		teleport_to("snow")
		return
	if check(notes, "CAFE"):
		Main.singleton.bee.energy_for_life()
		return
	if check(notes, "CABBAGE"):
		teleport_to("red")
		return
	if check(notes, "BEAD"):
		return
	if check(notes, "BACG"):
		teleport_to("home")
		return
	if check(notes, "BEDDED"):
		if Main.singleton.time.time > 0.5:
			Main.singleton.time.time = 1
		return

func teleport_to(target: String):
	SoundEffects.singleton.add(36, Main.bee_pos())
	SoundEffects.singleton.add(44, Main.bee_pos(), 2)
	await get_tree().create_timer(0.3).timeout
	SoundEffects.singleton.add(42, Main.bee_pos())
	Main.singleton.bee.teleport(target)
