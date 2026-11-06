extends Node2D

@export var amount := 100
@export var width := 5000
@export var height := 1000
@export var sprites: Array[Texture2D]
@export var size_min := 1.0
@export var size_max := 2.0
@export var alpha := 0.5
@export var speed_min := 1.0
@export var speed_max := 2.0
@export var cloud_material: Material

var clouds: Array[Sprite2D] = []
var speeds: Array[float] = []

func _ready() -> void:
	for i in amount:
		var cloud = Sprite2D.new()
		cloud.texture = sprites.pick_random()
		cloud.scale *= Vector2.ONE * randf_range(size_min, size_max)
		cloud.self_modulate = Color(1, 1, 1, alpha)
		cloud.global_position = Vector2(randf_range(-width, width), randf_range(-height, height))
		cloud.material = cloud_material
		speeds.append(randf_range(speed_min, speed_max))
		clouds.append(cloud)
		add_child(cloud)

func _process(delta) -> void:
	for i in clouds.size():
		clouds[i].position += Vector2.LEFT * speeds[i] * delta
		if clouds[i].global_position.x > width: clouds[i].global_position.x = -width
		if clouds[i].global_position.x < -width: clouds[i].global_position.x = width
