extends Node2D

@export var winds: Array[Wind]
@export var center_point: Node2D

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	call_deferred("add")

func add():
	var pos = center_point.global_position + Vector2(randf_range(-3000, 3000), randf_range(-1500, 1500))
	var wind = winds.filter(func(w): return not w.visible).pick_random()
	if wind: wind.restart(pos)
	await get_tree().create_timer(randf_range(0, 1.0)).timeout
	add()
