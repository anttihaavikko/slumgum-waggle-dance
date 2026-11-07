class_name Main extends Node

@export var harvester: Harvester
@export var inventory: Inventory
@export var item_db: ItemManager
@export var stations: Array[StationMenu]
@export var held: Slot
@export var builder: Builder

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
	Effects.singleton.pop(message, singleton.bee.body.global_position + Vector2.UP * 100)

func _process(_delta) -> void:
	held.global_position = held.get_global_mouse_position()

static func drop(item: Item, equipment: Equipment) -> Pickup:
	if item:
		return singleton.item_db.spawn(item.data.item_id, singleton.bee.body.global_position, item.amount)
	if equipment:
		return singleton.item_db.spawn(Item.Id.Equipment, singleton.bee.body.global_position, 1, equipment.identifier)
	return null
