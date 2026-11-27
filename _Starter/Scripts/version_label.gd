extends Node

@export var label: Control
@export var prefix: String

func _ready() -> void:
	if label is Label or label is RichTextLabel:
		label.text = "%s%s" % [prefix, ProjectSettings.get_setting("application/config/version")]
