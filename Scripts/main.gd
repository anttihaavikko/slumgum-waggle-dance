class_name Main extends Node

@export var harvester: Harvester
@export var inventory: Inventory
@export var item_db: ItemManager
@export var stations: Array[StationMenu]
@export var held: Slot
@export var builder: Builder
@export var time: Schedule
@export var explosion_shape: ShapeCast2D
@export var bird_prefab: PackedScene

var station: StationMenu
var bee: Bee
var flowers: Array[Flower] = []
var islands: Array[Island] = []
var bird: Bird

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

static func pop(message: String, offset: float = 0.0):
	var dir = Vector2.ONE.rotated(randf() * TAU).normalized() * offset
	Effects.singleton.pop(message, singleton.bee.body.global_position + Vector2.UP * 100 + dir)

func _process(_delta) -> void:
	held.global_position = held.get_global_mouse_position() + Vector2.UP * 55

static func drop(item: Item, equipment: Equipment) -> Pickup:
	if item:
		return singleton.item_db.spawn(item.data.item_id, singleton.bee.body.global_position, item.amount)
	if equipment:
		return singleton.item_db.spawn(Item.Id.Equipment, singleton.bee.body.global_position, 1, equipment.identifier)
	return null

static func spawn_item(item: Item.Id, pos: Vector2) -> Pickup:
	return singleton.item_db.spawn(item, pos, 1)

static func shake(amount: float, duration: float):
	singleton.bee.cam.shake(amount, duration)

static func get_item_data(id: Item.Id) -> ItemData:
	return singleton.item_db.items[id]

func cleanup():
	flowers = flowers.filter(func(f): return f)

func spawn_bird():
	if bird: return
	bird = bird_prefab.instantiate() as Bird
	bird.global_position = bee.body.global_position + Vector2.UP * 5000
	get_parent().add_child(bird)
