class_name MovingValue

var value := 0.0
var target := 0.0
var speed: float

func _init(start_value: float, spd: float = 10) -> void:
	value = start_value
	target = start_value
	speed = spd

func update(delta: float):
	value = clampf(value + signf(target - value) * delta * speed, 0, 1)
