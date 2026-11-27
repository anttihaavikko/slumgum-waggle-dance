extends Node

@export var hud: Control
@export var start_button: Button
@export var logo: Control
@export var cam: Camera2D
@export var settings: OptionsMenu
@export var queen: Queen
@export var bars: Array[Control]

func _ready() -> void:
	start_button.pressed.connect(start)
	hud.hide()
	await get_tree().process_frame
	cam.zoom = Vector2.ONE * 0.5

func _process(_delta) -> void:
	if not hud.visible and Input.is_action_just_pressed("interact"):
		start()

func start():
	hud.show()
	start_button.hide()
	logo.hide()
	Main.singleton.started = true
	for b in bars:
		get_tree().create_tween().tween_property(b, "scale", Vector2(1, 0), 0.3).set_trans(Tween.TRANS_BOUNCE)
	get_tree().create_tween().tween_property(cam, "zoom", settings.get_camera_zoom(), 0.6).set_trans(Tween.TRANS_QUAD)
	await get_tree().create_timer(0.3).timeout
	queen.appear(queen)
