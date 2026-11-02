class_name Bee extends Node2D

@export var body: RigidBody2D
@export var lander: RigidBody2D
@export var wings: AnimationPlayer

var thrust = 1.5
var turning = 1.0

func _process(delta) -> void:
	var rot = Input.get_axis("left", "right")
	var acc = Input.get_axis("accelerate", "brake")
	body.apply_torque(rot * delta * 5000000 * turning)
	body.apply_force(body.transform.y * acc * thrust * 100000 * delta)
	wings.speed_scale = 1.0 + absf(acc) * 3.0
