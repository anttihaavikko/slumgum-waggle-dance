class_name Main extends Node

@export var harvester: Harvester
@export var inventory: Inventory
@export var item_db: ItemManager
@export var stations: Array[StationMenu]
@export var held: Slot

var station: StationMenu
var bee: Bee

static var singleton: Main = null

func _enter_tree() -> void:
	if singleton == null:
		singleton = self

func _exit_tree() -> void:
	if singleton == self:
		singleton = null

func _init() -> void:
	if singleton == null:
		singleton = self

static func pop(message: String):
	Effects.singleton.pop(message, singleton.bee.body.global_position)

func _process(_delta) -> void:
	held.global_position = held.get_global_mouse_position()

static func drop(item: Item, equipment: Equipment):
	if item:
		singleton.item_db.spawn(item.data.item_id, singleton.bee.body.global_position, item.amount)
	if equipment:
		singleton.item_db.spawn(Item.Id.Equipment, singleton.bee.body.global_position, 1, equipment.identifier)
