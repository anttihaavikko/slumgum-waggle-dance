class_name Tooltip extends Control

@export var label: RichTextLabel

func _ready() -> void:
	hide()

func show_for(slot: Slot, pos: Vector2):
	if slot.is_empty():
		hide()
		return
	global_position = pos
	var title := slot.get_title().to_upper()
	var desc := slot.get_description()
	label.text = "[font_size=30]%s[/font_size]\n%s" % [title, desc]
	show()
