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
@export var new_marker: Texture2D
@export var notifications: Notifications

var station: StationMenu
var bee: Bee
var flowers: Array[Flower] = []
var islands: Array[Island] = []
var birds: Array[Bird] = []
var seen: Array[Item.Id] = [Item.Id.Nectar]
var built: Array[BuildPiece.Id] = [BuildPiece.Id.Platform, BuildPiece.Id.Support, BuildPiece.Id.Core]
var crafted: Array[Equipment.Id] = []
var died := false
var rank := 0:
	set(val):
		rank = min(rank + 1, ranks.size() - 1)
var ranks = ['newbee', 'private', 'corporal', 'sergeant', 'officer', 'lieutenant', 'captain', 'major', 'colonel', 'general']

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

func get_rank_name() -> String:
	return ranks[rank]

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

func remove_bird(bird: Bird):
	birds.remove_at(birds.find(bird))

func spawn_bird(forced := false):
	if birds.size() > 0 and not forced: return
	var bird = bird_prefab.instantiate() as Bird
	birds.append(bird)
	bird.global_position = bee.body.global_position + Vector2.UP * 5000
	get_parent().add_child(bird)

func has_seen_materials(recipe: Dictionary[Item.Id, int]):
	for id in recipe.keys():
		if not seen.has(id):
			return false
	return true

func mark_seen(id: Item.Id):
	if not seen.has(id):
		seen.append(id)
		for piece in builder.pieces:
			if piece.recipe.has(id) and Item.can_make(piece.recipe, seen):
				notifications.add(Utils.colorize("New build piece: (%s)" % [piece.title.to_upper()], "#FFBA49"))
		for eq in bee.tools:
			if eq.recipe.has(id) and Item.can_make(eq.recipe, seen):
				notifications.add(Utils.colorize("New recipe: (%s)" % [eq.name.to_upper()], "#FFBA49"))

func mark_crafted(id: Equipment.Id):
	if not crafted.has(id):
		crafted.append(id)

func mark_built(id: BuildPiece.Id):
	if not built.has(id):
		built.append(id)
