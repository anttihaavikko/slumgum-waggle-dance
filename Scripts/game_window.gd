class_name GameWindow extends Control

@export var button: Button
@export var has_close_button := true:
	set(val):
		has_close_button = val
		button.visible = val
@export var title_label: RichTextLabel
@export var title: String:
	set(val):
		title = val
		if title_label: title_label.text = val

signal closed

func _ready() -> void:
	button.pressed.connect(close)

func close():
	closed.emit()
