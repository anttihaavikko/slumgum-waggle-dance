class_name Station extends Node2D

enum Id {
	Core,
	Box
}

@export var identifier: Id
@export var title: String
@export var button: Button
@export var center: Node2D

var menu: StationMenu

func _ready() -> void:
	menu = Main.singleton.stations[identifier]
	button.pressed.connect(open)
	button.mouse_entered.connect(announce)

func announce():
	Effects.singleton.pop(title, center.global_position)

func open():
	if menu.visible:
		menu.hide()
		return
	menu.show()
