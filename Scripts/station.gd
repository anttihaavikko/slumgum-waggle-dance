class_name Station extends BuildPiece

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
	Effects.singleton.pop(title.to_upper(), center.global_position + Vector2.UP * 100)
	cooldown = 0.5

func open():
	if Main.singleton.builder.held: return
	if not menu: return
	if menu.is_open():
		menu.close()
		return
	menu.open(self)
