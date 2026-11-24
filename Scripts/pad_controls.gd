extends Node

@export var input_detection: InputDetection

var closest_station: Station

func _process(_delta) -> void:
	find_closest_station()

	if closest_station and Input.is_action_just_pressed("interact") and not Main.singleton.station:
		closest_station.open()

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
