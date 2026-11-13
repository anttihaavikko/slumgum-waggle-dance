class_name Preview extends Control

@export var win: GameWindow
@export var craft_button: Button
@export var description: RichTextLabel
@export var materials: RichTextLabel

var equipmment: Equipment

func _ready() -> void:
	win.hide()
	craft_button.pressed.connect(craft)

func close():
	win.hide()

func open():
	win.show()

func show_for(eq: Equipment):
	win.show()
	win.title = eq.name.to_upper()
	description.text = eq.description
	equipmment = eq
	materials.text = ""
	var db = Main.singleton.item_db.items
	for id: Item.Id in eq.recipe.keys():
		var item = db[id] as ItemData
		var have = Main.singleton.inventory.get_count(id)
		var have_color = "#20A39E" if have >= eq.recipe[id] else "#EF5B5B"
		materials.text += "[color=%s]%d[/color] x %s [img=36 color=#%s]%s[/img] (got [color=%s]%d[/color])\n" % [
			have_color,
			eq.recipe[id],
			item.title,
			item.color.to_html(),
			item.sprite.get_path(),
			have_color,
			have
		]

func craft():
	Main.singleton.inventory.add_equipment(equipmment)
	Main.shake(10, 0.15)
