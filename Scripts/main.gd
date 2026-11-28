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
@export var input_detection: InputDetection
@export var buttons: Array[Button]
@export var options: OptionsMenu
@export var hat: Hat
@export var tailor: Tailor

var debug_start := false
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
var object_index := 0
var hovering := false
var sleep_buff := 0
var free_platforms := false
var compass_spots: Array[Node2D] = []
var relic_pool: Array[Item.Id] = []
var egg_pool: Array[Item.Id] = []
var started := false
var death_save := false

var all_relics := [Item.Id.RelicEnergy, Item.Id.RelicHealth, Item.Id.RelicInventory]
var all_eggs := [Item.Id.Egg, Item.Id.EggDamage]

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

func _ready() -> void:
	for b in buttons: register_hoverable(b)
	relic_pool.append_array(all_relics)
	relic_pool.shuffle()
	egg_pool.append_array(all_eggs)
	egg_pool.shuffle()

func get_relic() -> Item.Id:
	if relic_pool.size() > 0:
		return relic_pool.pop_front()
	return all_relics.pick_random()

func get_egg() -> Item.Id:
	if egg_pool.size() > 0:
		return egg_pool.pop_front()
	return all_eggs.pick_random()

func get_rank_name() -> String:
	return ranks[rank]

static func pop(message: String, offset: float = 0.0):
	var dir = Vector2.ONE.rotated(randf() * TAU).normalized() * offset
	Effects.singleton.pop("[wave amp=30]%s" % [message], singleton.bee.body.global_position + Vector2.UP * 100 + dir)

func _process(_delta) -> void:
	if not input_detection.using_pad:
		held.global_position = held.get_global_mouse_position() + Vector2.UP * 55

static func drop_at(item: Item, equipment: Equipment, pos: Vector2) -> Pickup:
	if item:
		var i = singleton.item_db.spawn(item.data.item_id, pos, item.amount)
		i.item.equip = item.equip
		return i
	if equipment:
		return singleton.item_db.spawn(Item.Id.Equipment, pos, 1, equipment.identifier)
	return null

static func drop(item: Item, equipment: Equipment) -> Pickup:
	return drop_at(item, equipment, singleton.bee.body.global_position)

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
	Music.bird_attack(true)
	open_doors(Hut.DoorType.Bird, -1)
	var bird = bird_prefab.instantiate() as Bird
	birds.append(bird)
	bird.global_position = bee.body.global_position + Vector2.UP * 6000
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
		for h in tailor.recipes:
			if h.recipe.has(id) and Item.can_make(h.recipe, seen):
				notifications.add(Utils.colorize("New hat part: (%s)" % [h.title.to_upper()], "#FFBA49"))

func mark_crafted(id: Equipment.Id):
	if not crafted.has(id):
		crafted.append(id)

func mark_built(id: BuildPiece.Id):
	if not built.has(id):
		built.append(id)

func toggle_fullscreen():
	OptionsMenu.toggle_fullscreen_static()
	get_viewport().gui_release_focus()

func get_door_hint() -> Texture2D:
	if not door_hints_init:
		door_hints_init = true
		door_hint_pool = door_hints.map(func(h): return door_hints.find(h))
		door_hint_pool.shuffle()
	if not door_hint_pool: return null
	return door_hints[door_hint_pool.pop_front()]

func load():
	if OS.is_debug_build() and debug_start: data = SaveData.new()
	else: data = SaveData.load()
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

	for i in data.inventory.size():
		var dat = data.inventory[i]
		if not dat: continue
		if dat[0] == Item.Id.Equipment:
			inventory.slots[i].add_equipment(bee.tools[dat[2]])
		else:
			inventory.slots[i].add_item(item_db.items[dat[0]], dat[1])

	inventory.focus(0)

	evaluate_stats()
	bee.energy_left = bee.energy_max
	update_hat()

func save():
	if OS.is_debug_build() and debug_start: return
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
	stinger.morphs = false
	stinger.deflects = false
	var health := 10
	var energy := 30 if sleep_buff > 0 else 20
	var inventory_size := 7
	bee.can_dash = false
	bee.can_hover = false
	free_platforms = false
	for piece in builder.built_pieces:
		if piece is not Station: continue
		if piece.identifier == BuildPiece.Id.Totem:
			for i: Item in piece.inputs:
				if not i: continue
				if i.data.item_id == Item.Id.RelicEnergy:
					energy += 10
				if i.data.item_id == Item.Id.RelicHealth:
					health += 5
				if i.data.item_id == Item.Id.EyeGreatTit:
					bee.can_dash = true
				if i.data.item_id == Item.Id.EyeBeeEater:
					bee.can_hover = true
				if i.data.item_id == Item.Id.EyeShrike:
					free_platforms = true
				if i.data.item_id == Item.Id.RelicInventory:
					inventory_size += 1
		if piece.identifier == BuildPiece.Id.Cup:
			for i: Item in piece.inputs:
				if not i: continue
				if i.data.item_id == Item.Id.EggDamage:
					stinger.damage += 1
				if i.data.item_id == Item.Id.EggDefender:
					stinger.deflects = true
				if i.data.item_id == Item.Id.EggPolymorph:
					stinger.morphs = true

	# print("Stinger damage: ", stinger.damage)
	# print("Health: ", health)
	# print("Energy: ", energy)
	bee.health.max_hp = health
	bee.energy_max = energy
	bee.energy.max_hp = energy
	inventory.setup_size(inventory_size)
	stinger.sparkles.visible = stinger.damage > 3
	stinger.sparks.visible = stinger.morphs

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

static func bee_pos() -> Vector2:
	return singleton.bee.body.global_position

func register_hoverable(button: Button):
	button.mouse_entered.connect(func(): hovering = true)
	button.mouse_exited.connect(func(): hovering = false)

func get_compass_dir(pos: Vector2) -> Vector2:
	var closest = Utils.find_closest(compass_spots, pos)
	if not closest: return Vector2.ZERO
	return (closest.global_position - pos).normalized()

func remove_compass_spot(node: Node2D):
	if compass_spots.has(node):
		compass_spots.remove_at(compass_spots.find(node))

func toggle_tooltip():
	if tooltip.visible:
		tooltip.hide()
	else:
		inventory.current().hover_on()

func save_and_quit():
	if started: save()
	options.quit()

func stuck():
	if not started: return
	bee.body.apply_impulse(Vector2.UP * 1500 + randf_range(-1, 1) * Vector2.RIGHT * 500)
	bee.body.apply_torque_impulse(randf_range(-1, 1) * 100000)
	bee.die()

func inventory_saved():
	await get_tree().create_timer(0.5).timeout
	Main.pop("MUSICAL GRACE!")
	Main.singleton.death_save = false

func update_hat():
	hat.visible = data.hat_parts[0] != ""
	hat.feelers.visible = not hat.visible
	hat.string_sprite.visible = data.hat_parts[1] != ""
	hat.feather.visible = data.hat_parts[2] != ""
	if not hat.visible and (hat.string_sprite.visible or hat.feather.visible):
		pop("CAN'T WEAR ACCESSORIES WITHOUT A HAT")
	for id in data.hat_parts:
		var index := tailor.recipes.find_custom(func(h: HatPart): return h.resource_scene_unique_id == id)
		var hat_part := tailor.recipes[index]
		if hat_part.slot == 0:
			hat.main_sprite.self_modulate = hat_part.color
			hat.main_sprite.texture = hat_part.sprite
		if hat_part.slot == 1:
			hat.string_sprite.self_modulate = hat_part.color
			hat.string_sprite.texture = hat_part.sprite
			hat.string_sprite.position = hat.string_pos + hat_part.offset
		if hat_part.slot == 2:
			hat.feather.texture = hat_part.sprite

func is_wearing(hp: HatPart) -> bool:
	return data.hat_parts.has(hp.resource_scene_unique_id)
