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
@export var door_hints: Array[Texture2D]
@export var tooltip: Tooltip

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
var door_hint_pool: Array
var door_hints_init := false
var data: SaveData
var huts: Array[Hut] = []

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

static func spawn_item(item: Item.Id, pos: Vector2, amount := 1) -> Pickup:
	return singleton.item_db.spawn(item, pos, amount)

static func shake(amount: float, duration: float):
	singleton.bee.cam.shake(amount, duration)

static func get_item_data(id: Item.Id) -> ItemData:
	return singleton.item_db.items[id]

func cleanup():
	flowers = flowers.filter(func(f): return f)

func remove_bird(bird: Bird):
	birds.remove_at(birds.find(bird))
	if birds.size() == 0:
		close_doors(Hut.DoorType.Bird)

func spawn_bird(forced := false):
	if birds.size() > 0 and not forced: return
	open_doors(Hut.DoorType.Bird, -1)
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

func toggle_fullscreen():
	OptionsMenu.toggle_fullscreen_static()

func get_door_hint() -> Texture2D:
	if not door_hints_init:
		door_hints_init = true
		door_hint_pool = door_hints.map(func(h): return door_hints.find(h))
		door_hint_pool.shuffle()
	if not door_hint_pool: return null
	return door_hints[door_hint_pool.pop_front()]

func load():
	data = SaveData.load()
	time.day = data.day
	time.time = data.time
	rank = data.rank
	for d in data.seen: seen.append(d)
	for d in data.built: built.append(d)
	for d in data.crafted: crafted.append(d)
	builder.load()
	await get_tree().process_frame
	bee.health.hp = max(data.health, 1)
	bee.teleport_to(Vector2(data.x, data.y))
	evaluate_stats()

func save():
	data.day = time.day
	data.rank = rank
	data.inventory = inventory.get_for_save()
	data.seen = seen
	data.built = built
	data.crafted = crafted
	data.buildings = []
	data.health = bee.health.hp
	data.x = bee.body.global_position.x
	data.y = bee.body.global_position.y
	data.time = time.time
	for b in builder.built_pieces:
		data.buildings.append(b.get_for_save())
	data.save()

func evaluate_stats():
	var stinger := bee.tools[Equipment.Id.Stinger] as Weapon
	stinger.damage = 3
	var health := 10
	var energy := 20
	for piece in builder.built_pieces:
		if piece is not Station: continue
		if piece.identifier == BuildPiece.Id.Totem:
			for i: Item in piece.inputs:
				if not i: continue
				if i.data.item_id == Item.Id.RelicEnergy:
					energy += 10
				if i.data.item_id == Item.Id.RelicHealth:
					health += 5
		if piece.identifier == BuildPiece.Id.Cup:
			for i: Item in piece.inputs:
				if not i: continue
				if i.data.item_id == Item.Id.EggDamage:
					stinger.damage += 1

	# print("Stinger damage: ", stinger.damage)
	# print("Health: ", health)
	# print("Energy: ", energy)
	bee.health.max_hp = health
	bee.energy_max = energy
	bee.energy.max_hp = energy

func open_doors(type: Hut.DoorType, close_delay := 3.0):
	for hut in huts:
		if hut.door_type == type:
			hut.door.open()
			if close_delay > 0:
				await get_tree().create_timer(close_delay).timeout
				hut.door.close()

func close_doors(type: Hut.DoorType):
	for hut in huts:
		if hut.door_type == type:
			hut.door.close()
