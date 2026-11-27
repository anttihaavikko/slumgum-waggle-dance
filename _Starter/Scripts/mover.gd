class_name Mover extends Node2D

@export var target: Node

@export var moves: bool
@export var move_direction: Vector2
@export var move_speed := 5.0

@export var scales: bool
@export var scale_amount: Vector2
@export var scale_speed := 5.0

@export var single_direction: bool
@export var time_offset := 0.0

var start_pos: Vector2
var time: float
var start_scale: Vector2

func _ready() -> void:
	start_pos = get_target().position
	start_scale = get_target().scale

func get_target():
	return target if target else self

func _process(delta: float) -> void:
	time += delta

	if moves:
		var dir := sin(time * move_speed + time_offset)
		get_target().position = start_pos + move_direction * (abs(dir) if single_direction else dir)

	if scales:
		var dir := sin(time * scale_speed + time_offset)
		get_target().scale = start_scale + scale_amount * (abs(dir) if single_direction else dir)
