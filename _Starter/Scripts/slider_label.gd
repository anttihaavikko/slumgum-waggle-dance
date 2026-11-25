extends RichTextLabel

var slider: Slider

func _ready() -> void:
	slider = get_parent()
	slider.value_changed.connect(update)
	update(0)

func update(_val):
	text = "%d%%" % [slider.value * 100]
