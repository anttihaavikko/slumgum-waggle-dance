extends Node

@export var input_detection: InputDetection

var closest_station: Station

func _process(_delta) -> void:
	find_closest_station()

	if closest_station and Input.is_action_just_pressed("interact") and not Main.singleton.station and not Main.singleton.builder.picker.visible:
		closest_station.open()

	if Input.is_action_just_pressed("toggle_tooltip"):
		Main.singleton.toggle_tooltip()

	var x = Input.get_axis("look_left", "look_right")
	var y = Input.get_axis("look_up", "look_down")
	input_detection.fake_mouse += Vector2(x, y) * _delta * 1000

func find_closest_station():
	if not input_detection.using_pad:
		closest_station = null
		return
	var bp := Main.bee_pos()
	var stations = Main.singleton.builder.built_pieces.filter(func (b): return b is Station and b.interactable)
	stations.append(Main.singleton.builder.starters[0])
	var closest := Utils.find_closest(stations, bp)
	if bp.distance_to(closest.global_position) > 300:
		closest_station = null
		return
	if closest_station != closest:
		closest_station = closest
		closest_station.announce(true)
