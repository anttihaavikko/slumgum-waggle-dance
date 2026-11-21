extends Node

@export var body: RigidBody2D

var phase := 0
var dir := 0.0

signal flipped

func _physics_process(_delta) -> void:
	if signf(body.angular_velocity) != dir:
		phase = 0
	dir = signf(body.angular_velocity)
	if (phase == 0 or phase == 2) and absf(body.rotation_degrees) < 5:
		phase += 1
	if phase == 1 and absf(absf(body.rotation_degrees) - 180) < 5:
		phase = 2
	if phase == 3:
		phase = 0
		flipped.emit()
