class_name Station extends BuildPiece

enum Id {
	Core,
	Box
}

@export var identifier: Id
@export var title: String
@export var button: Button
@export var center: Node2D

var inputs: Array[Item] = []
var outputs: Array[Item] = []

var menu: StationMenu
var cooldown := 0.0

func _ready() -> void:
	menu = Main.singleton.stations[identifier]
	button.pressed.connect(open)
	button.mouse_entered.connect(announce)

func _process(delta) -> void:
	cooldown -= delta

func announce():
	if cooldown > 0: return
	if Main.singleton.builder.held: return
	Effects.singleton.pop(title, center.global_position)
	cooldown = 0.5

func open():
	if Main.singleton.builder.held: return
	if menu.visible:
		menu.hide()
		return
	menu.open(self)
