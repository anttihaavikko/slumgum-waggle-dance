class_name DoubleTabDetect extends Node

@export var actions: Array[String]
@export var reset_delay := 0.5

var previous: String
var timer: Timer

signal triggered(action_name: String)

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(reset)

func reset():
	previous = ""

func _process(_delta) -> void:
	for a in actions:
		if Input.is_action_just_pressed(a):
			timer.start(reset_delay)
			if a == previous:
				triggered.emit(a)
				previous = ""
			else:
				previous = a
