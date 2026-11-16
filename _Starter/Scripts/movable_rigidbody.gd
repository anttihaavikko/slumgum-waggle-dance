class_name MovableRigidbody
extends RigidBody2D

var reset_state := false
var targetPosition: Vector2
var targetRotation: float

func _integrate_forces(state):
	if reset_state:
		state.transform = Transform2D(targetRotation, targetPosition)
		reset_state = false

func move_to(target: Vector2, rot: float):
	targetPosition = target
	targetRotation = rot
	reset_state = true

func reset_speeds():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
