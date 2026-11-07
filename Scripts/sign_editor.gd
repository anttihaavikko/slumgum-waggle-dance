extends StationMenu

@export var field: TextEdit

func _ready() -> void:
	field.gui_input.connect(update)
	super._ready()

func update(_event: InputEvent):
	station.label.text = field.text

func open(source: Station):
	super.open(source)
	field.grab_focus()
	field.select_all()
