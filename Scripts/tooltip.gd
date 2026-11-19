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
	var desc := Utils.colorize(slot.get_description(), "#FFBA49")
	label.text = "[font_size=30][color=#fff]%s[/color][/font_size]\n%s" % [title, desc]
	show()
