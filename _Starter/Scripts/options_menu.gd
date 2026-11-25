class_name OptionsMenu
extends SlidingPanel

@export var toggle_action: String
@export var toggle_button_top: Button
@export var toggle_button_bottom: Button
@export var music: Slider
@export var sounds: Slider
@export var scaler: Slider
@export var distance: Slider
@export var extra_panel: SlidingPanel
@export var toggle_button_on_top: bool
@export var cam: Camera2D
@export var extra_close_action: String
@export var container: Control

var saver = Saver.new("settings.json")
var data: SettingsData
var default_zoom := Vector2.ZERO
var can_open := true

func _ready():
	super._ready()
	if cam: default_zoom = cam.zoom
	if toggle_button_top: toggle_button_top.visible = toggle_button_on_top
	if toggle_button_bottom: toggle_button_bottom.visible = not toggle_button_on_top
	show()
	if toggle_button_top: toggle_button_top.pressed.connect(button_toggle)
	if toggle_button_bottom: toggle_button_bottom.pressed.connect(toggle)
	data = saver.load(func(): return SettingsData.new()) as SettingsData
	# print("%f/%f" % [data.music, data.sounds])
	music.value = data.music
	sounds.value = data.sounds
	scaler.value = data.scale
	distance.value = data.distance
	changed(0)
	music.value_changed.connect(changed)
	sounds.value_changed.connect(changed)
	scaler.value_changed.connect(changed)
	distance.value_changed.connect(changed)
	on_toggle.connect(toggled)

func toggled(state: bool):
	if state:
		music.grab_focus()
	if not state:
		get_viewport().gui_release_focus()
	if not state: await get_tree().create_timer(duration).timeout
	container.visible = state

func changed(_val):
	AudioServer.set_bus_volume_linear(1, music.value * 2)
	AudioServer.set_bus_volume_linear(2, sounds.value * 2)
	get_tree().root.content_scale_factor = scaler.value
	if cam: cam.zoom = default_zoom * distance.value / scaler.value
	data.music = music.value
	data.sounds = sounds.value
	data.scale = scaler.value
	data.distance = distance.value

func button_toggle():
	if not can_open: return
	super.toggle()
	if extra_panel and extra_panel.open:
		extra_panel.toggle()
	saver.save(data)

func _input(_event):
	if Input.is_action_just_pressed(toggle_action):
		toggle()
	if open and extra_close_action and Input.is_action_just_pressed(extra_close_action):
		toggle()

func quit():
	Blinders.singleton.quit()

func change_scene(scene: String = "start") -> void:
	Blinders.singleton.change_scene(scene)

func restart():
	toggle()
	Blinders.singleton.close()
	await Blinders.singleton.closed
	get_tree().reload_current_scene()

func toggle_fullscreen():
	OptionsMenu.toggle_fullscreen_static()

static func toggle_fullscreen_static():
	var full := DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
