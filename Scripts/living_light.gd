extends PointLight2D

@export var die_after := 0.0

var time := 0.0
var size := 1.0

func _ready() -> void:
	size = texture_scale
	if die_after > 0:
		await get_tree().create_timer(die_after).timeout
		queue_free()

func _process(delta) -> void:
	time += delta * 20.0
	texture_scale = size + sin(time) * 0.01
	energy = 1.0 + sin(time) * 0.006
