class_name Bee extends Node2D

# slumgum scout
# waggle dance
# waltz
#
# oil press etc
# hats
# crab spiders
# beewolves (wasp)
# bird eyes
# sleep boost
# songs
# more huts
# more obelisks
# menu
# pickup permanence
# other pollens
#
# inventory slots
# compass
# free platforms
#
# AMBForst_Late Spring.A Quiet Forest Edge.Hot.Sunny.Birds.Mosquitoes 2_EM by newlocknew -- https://freesound.org/s/856018/ -- License: Creative Commons 0
# amb_forest_night.wav by Dokuta_Gerovv -- https://freesound.org/s/662095/ -- License: Creative Commons 0

@export var body: MovableRigidbody
@export var lander: MovableRigidbody
@export var wings: AnimationPlayer
@export var inventory: Inventory
@export var tools: Array[Equipment]
@export var hands: Node2D
@export var health: HealthDisplay
@export var energy: HealthDisplay
@export var item: Sprite2D
@export var cam: Camera
@export var builder: Builder
@export var face: Face
@export var crosses: Node2D
@export var bomb_prefab: PackedScene
@export var visuals: Node2D
@export var leg_container: Node2D
@export var spring_core_prefab: PackedScene
@export var core_remote: RemoteTransform2D
@export var hands_wrap: Node2D
@export var heal_particles: CPUParticles2D
@export var face_mover: Node2D
@export var buzz: AudioStreamPlayer2D
@export var charge_particles: CPUParticles2D
@export var charging_humm: AudioStreamPlayer2D

var thrust = 1.5
var turning = 1.0
var energy_max := 20.0
var energy_left := energy_max
var charging := false
var landed := false
var zoomed := false
var dead := false
var stretch := 0.0
var spring_core: SpringCore
var buzz_volume = MovingValue.new(0, 5)
var has_consumed_energy := false
var charge_volume = MovingValue.new(0, 10)

var current: Equipment

func _ready() -> void:
	buzz.volume_linear = 0
	charging_humm.volume_linear = 0
	Main.singleton.bee = self
	Main.singleton.load()
	# global_position += Vector2.RIGHT * -500
	inventory.create_slots(7)
	for s in inventory.slots.size():
		inventory.slots[s].in_bar = true
		inventory.slots[s].show_key("%d" % [s + 1])
	seed(Main.singleton.data.world_seed)
	energy.max_hp = roundi(energy_max)
	await get_tree().process_frame
	current_changed()
	inventory.changed.connect(current_changed)
	lander.body_entered.connect(land)
	lander.body_exited.connect(func(_o): landed = false)
	body.body_entered.connect(collide)
	inventory.announces = true
	create_spring_core()
	# await get_tree().create_timer(1).timeout
	# inventory.add_item(Item.Id.Wax, 20)
	add_console_commands()

	# print(OS.get_data_dir())
	# print(Main.singleton.data.inventory)
	# inventory.populate_from(Main.singleton.data.inventory)
	for i in Main.singleton.data.inventory.size():
		var data = Main.singleton.data.inventory[i]
		if not data: continue
		if data[0] == Item.Id.Equipment:
			inventory.slots[i].add_equipment(tools[data[2]])
		else:
			inventory.slots[i].add_item(Main.singleton.item_db.items[data[0]], data[1])

	inventory.focus(0)
	# DisplayServer.window_set_size(Vector2i(320, 240))
	# get_tree().root.content_scale_size = Vector2i(320, 240)
	# get_tree().root.content_scale_factor = 2

	if OS.is_debug_build():
		analyze()

	# await get_tree().process_frame
	# if OS.is_debug_build():
	# 	inventory.add_equipment(tools[Equipment.Id.Hammer])
		# inventory.add_equipment(tools[Equipment.Id.Scythe])
		# inventory.add_equipment(tools[Equipment.Id.Blowpipe])
		# inventory.add_equipment(tools[Equipment.Id.Guitar])
		# inventory.add_equipment(tools[Equipment.Id.Pickaxe])
		# inventory.add_equipment(tools[Equipment.Id.Paintbrush])
		# inventory.add_equipment(tools[Equipment.Id.Brush])
		# inventory.add_equipment(tools[Equipment.Id.Lantern])
		# inventory.add_item(Item.Id.Nectar, 20)
		# inventory.add_item(Item.Id.Honey, 20)
		# inventory.add_item(Item.Id.Wax, 20)
		# inventory.add_item(Item.Id.Resin, 20)
		# inventory.add_item(Item.Id.Acid, 20)
		# inventory.add_item(Item.Id.Pollen, 10)
		# inventory.add_item(Item.Id.Seed, 20)
		# inventory.add_item(Item.Id.String, 20)
		# inventory.add_item(Item.Id.Bomb, 10)

func add_console_commands():
	# if LimboConsole._commands.has("give"): return
	unregister_console("give")
	unregister_console("energy")
	unregister_console("heal")
	unregister_console("damage")
	unregister_console("anvil")
	unregister_console("teleport")
	unregister_console("recipe")
	unregister_console("die")
	unregister_console("save")
	unregister_console("bird")
	LimboConsole.register_command(console_spawn, "give", "spawns in an item or equipment")
	LimboConsole.add_argument_autocomplete_source("give", 0, get_all_spawnable_names)
	LimboConsole.register_command(fill_energy, "energy", "refill energy")
	LimboConsole.register_command(heal, "heal", "heal given amount")
	LimboConsole.register_command(damage, "damage", "take damage")
	LimboConsole.register_command(show_anvil_menu, "anvil", "opens anvil crafting menu")
	LimboConsole.register_command(teleport, "teleport", "teleport to position")
	LimboConsole.register_command(show_recipe, "recipe", "list recipe ingredients")
	LimboConsole.register_command(func(): Main.singleton.save(), "save", "save the game")
	LimboConsole.register_command(func(): damage(health.max_hp), "die", "die, useful if somehow stuck")
	LimboConsole.register_command(func(): Main.singleton.spawn_bird(), "bird", "spawn a bird")
	LimboConsole.add_argument_autocomplete_source("teleport", 0, func(): return ["home", "snow", "red"])
	LimboConsole.add_argument_autocomplete_source("recipe", 0, get_recipe_names)
	LimboConsole.add_argument_autocomplete_source("teleport", 1, func(): return ["list", "get"])
	LimboConsole.add_alias("tp", "teleport")
	LimboConsole.add_alias("item", "give")
	LimboConsole.add_alias("spawn", "give")
	LimboConsole.add_alias("i", "give")
	LimboConsole.add_alias("g", "give")
	LimboConsole.add_alias("add", "give")

func show_recipe(id: String, action := "list"):
	var index = builder.pieces.find_custom(func(p: PieceData): return as_id(p.title).begins_with(id))
	LimboConsole.info("%s:\n------" % [builder.pieces[index].title])
	var recipe = builder.pieces[index].recipe
	for part in recipe.keys():
		LimboConsole.info("%d x %s" % [recipe[part], Main.singleton.item_db.items[part].title])
		if action == "get":
			inventory.add_item(part, recipe[part])

func analyze():
	var totals: Dictionary[Item.Id, int] = {}
	for eq in tools:
		var line = []
		for part in eq.recipe.keys():
			line.append("%d x %s" % [eq.recipe[part], Main.singleton.item_db.items[part].title])
			if totals.has(part): totals[part] += eq.recipe[part]
			else: totals[part] = eq.recipe[part]
		print("%s: %s" % [eq.name, ", ".join(line)])
	for piece in builder.pieces:
		var line = []
		for part in piece.recipe.keys():
			line.append("%d x %s" % [piece.recipe[part], Main.singleton.item_db.items[part].title])
			if totals.has(part): totals[part] += piece.recipe[part]
			else: totals[part] = piece.recipe[part]
		print("%s: %s" % [piece.title, ", ".join(line)])
	print("---")
	for key in totals.keys():
		print("%s: %d" % [Main.get_item_data(key).title, totals[key]])

func get_recipe_names() -> Array:
	return builder.pieces.map(func(p: PieceData): return as_id(p.title))

func unregister_console(command: String):
	if LimboConsole._commands.has(command):
		LimboConsole.unregister_command(command)

func show_anvil_menu():
	Main.singleton.stations[BuildPiece.Id.Anvil].open(Main.singleton.builder.starters[0])
	pass

func console_spawn(item_name: String, amount := 20):
	if get_equip_names().has(item_name):
		inventory.add_equipment(tools[get_equip_names().find(item_name)])
	else:
		var i = get_item_names().find_custom(func(n: String): return n.begins_with(item_name))
		inventory.add_item(i, min(amount, Main.singleton.item_db.items[i].stack_size))

func get_all_spawnable_names() -> Array:
	var all = get_equip_names()
	all.append_array(get_item_names())
	return all

func get_equip_names() -> Array:
	return tools.map(func(t): return as_id(str(t.name)))

func as_id(text: String) -> String:
	return text.to_lower().replace(" ", "_")

func get_item_names() -> Array:
	return Main.singleton.item_db.items.map(func(i): return as_id(i.title))

func create_spring_core():
	if spring_core: spring_core.queue_free()
	spring_core = spring_core_prefab.instantiate() as SpringCore
	spring_core.position = to_local(body.global_position)
	await get_tree().process_frame
	add_child(spring_core)
	core_remote.remote_path = spring_core.core.get_path()

func throw(prefab: PackedScene):
	var obj = prefab.instantiate() as RigidBody2D
	obj.position = body.position
	obj.rotation = randf() * TAU
	var dir = get_global_mouse_position() - body.global_position
	add_child(obj)
	obj.apply_impulse(dir.normalized() * 1500)

func can_open() -> bool:
	return not current or not current.blocks_clicks()

func energy_for_life():
	fill_energy()
	damage(1)

func fill_energy():
	energy_left = energy_max
	energy.heal(999)
	heal_particles.emitting = true

func give_energy(amt := 1):
	energy_left = min(energy_left + amt, energy_max)
	energy.heal(amt)
	heal_particles.emitting = true

func heal_if_not_full(amt := 1):
	if not health.is_full():
		heal(amt)

func heal(amt := 1):
	if health.is_alive():
		SoundEffects.singleton.add(14, body.global_position)
		health.heal(amt)
		heal_particles.emitting = true

func die():
	SoundEffects.singleton.add(7, body.global_position, 0.5)
	health.hurt(999)
	inventory.drop(body.global_position)
	face.left_eye.hide()
	face.right_eye.hide()
	crosses.show()
	hands.hide()
	if current: current.hide()
	wings.stop()
	face.mouth.scale.y *= -1
	item.hide()
	await get_tree().create_timer(3).timeout
	teleport("home")
	Main.singleton.time.time = 1.0
	await get_tree().create_timer(0.1).timeout
	wings.play()
	crosses.hide()
	face.right_eye.show()
	face.left_eye.show()
	face.mouth.scale.y *= -1
	if current: current.show()
	else: hands.show()
	health.heal(999)
	dead = false
	Main.singleton.rank = 0
	Main.singleton.died = true

func teleport(target: String = "home"):
	var points = {
		"home": global_position,
		"red": Main.singleton.islands[1].get_spawn(),
		"snow": Main.singleton.islands[2].get_spawn()
	}
	if not points.has(target): return
	teleport_to(points[target])

func teleport_to(pos: Vector2):
	await get_tree().process_frame
	body.move_to(pos, 0)
	lander.move_to(pos + Vector2.DOWN * 133, 0)
	body.reset_speeds()
	lander.reset_speeds()
	await get_tree().process_frame
	create_spring_core()

func is_holding(id: Equipment.Id):
	return current and current.identifier == id

func danger():
	if randf() > 0.01 * Main.singleton.rank: return
	Main.singleton.call_deferred("spawn_bird")

func land(target: Node2D):
	if body.linear_velocity.length() > 10 or body.angular_velocity > 2:
		SoundEffects.singleton.add(0, lander.global_position)
	landed = true
	charging = false
	if target is Platform:
		charging = target.energized

	if charging and energy_left < energy_max * 0.9:
		SoundEffects.singleton.add(9, lander.global_position, 0.7)
		has_consumed_energy = true
	cam.shake(body.linear_velocity.length() * 0.01, 0.12)
	# stretch -= body.linear_velocity.y * 0.0002
	if not charging and energy.hp < 5 and not dead:
		danger()

func collide(_node: Node2D):
	var mag = body.linear_velocity.length()
	var threshold := 200.0
	var amt = roundf(mag / threshold)
	var p = lander.global_position
	SoundEffects.singleton.add(18, p, 0.5 + min(amt * 0.2, 0.6))
	SoundEffects.singleton.add(6, p, 0.5 + min(amt * 0.1, 0.4))
	if mag > threshold:
		cam.shake(amt * 5, 0.15)
		damage(amt)

func damage(amount: int):
	health.hurt(amount)
	if not health.is_alive() and not dead:
		dead = true
		die()

func current_changed():
	current = inventory.current().equipment
	hands.visible = not current
	var i = inventory.current().item
	item.visible = !!i
	if i:
		item.self_modulate = i.data.color
		item.texture = i.data.sprite
		item.position.y = -39 + i.data.hold_offset
		item.rotation_degrees = i.data.hold_rotation

func energy_crossed(dir: float, limit: float) -> bool:
	return energy_left > limit and energy_left + dir < limit

func energy_bling():
	await get_tree().create_timer(0.1).timeout
	# SoundEffects.singleton.add(19, body.global_position)
	SoundEffects.singleton.add(20, body.global_position)
	Effects.singleton.add(11, body.global_position)

func change_energy(dir: float, limit: float = energy_max):
	if has_consumed_energy and energy_left + dir >= energy_max:
		has_consumed_energy = false
		energy_bling()
	if limit < energy_max and energy_left > limit and dir > 0: return
	if energy_crossed(dir, 5.2) or energy_crossed(dir, 0):
		SoundEffects.singleton.add(8, body.global_position, 2)
	energy_left = clampf(energy_left + dir, 0, energy_max)
	energy.hp = roundi(energy_left)

func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.is_debug_build(): return

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Z:
			zoomed = not zoomed
			var z = 0.05 if zoomed else 0.3
			cam.zoom = Vector2.ONE * z

func _process(delta) -> void:
	var limit := 10.0
	var look_mod = (limit - clamp(body.linear_velocity.length(), 0, limit)) / limit
	cam.position = Vector2.ZERO.move_toward(to_local(Main.singleton.input_detection.get_position(body, 5000)), 300 * look_mod) + \
		body.linear_velocity * 0.5

	var show_charging = charging and landed and energy_left < energy_max
	charge_volume.target = 1 if show_charging else 0
	charge_volume.update(delta)
	charge_particles.emitting = charge_volume.value

	charging_humm.volume_linear = 1 if show_charging else 0
	charging_humm.pitch_scale = 1 + 0.3 * sin(Time.get_ticks_msec() * 0.01)

	if builder.held:
		cam.position = Vector2.ZERO

	var rot = Input.get_axis("left", "right")
	var acc = Input.get_axis("accelerate", "brake") if energy_left > 0 else 0.0
	var speed = 10.0 if OS.is_debug_build() and Input.is_action_pressed("shift") else 1.0
	if health.is_alive() and not LimboConsole.is_open():
		body.apply_torque(rot * delta * 5000000 * turning)
		body.apply_force(body.transform.y * acc * thrust * 100000 * delta * speed)
		wings.speed_scale = 1.0 + absf(acc) * 3.0
		if abs(acc) > 0.01:
			change_energy(-delta)

	buzz_volume.target = absf(acc)
	buzz_volume.update(delta)
	buzz.volume_linear = buzz_volume.value * 0.5

	# stretch -= clamp(signf(stretch) * delta * 0.5, -abs(stretch), abs(stretch))
	var diff = spring_core.get_direction()
	hands_wrap.position = diff * 1
	face_mover.position = -diff * 1
	stretch = diff.y * 0.004 - diff.x * 0.004
	stretch = clamp(stretch, -0.2, 0.2)
	visuals.scale = Vector2(1 - stretch, 1 + stretch)
	# leg_container.scale = visuals.scale

	if not health.is_alive(): return
	if LimboConsole.is_open(): return

	if landed:
		change_energy(delta * 5, energy_max if charging else 5.0)

	if current:
		current.update(delta)

	for i in 9:
		if Input.is_action_just_pressed("slot_%d" % [i + 1]) and i < inventory.slots.size():
			inventory.focus(i)

	if Input.is_action_just_pressed("primary"):
		use_selected_item()

	if builder.held and builder.held.can_rotate: return
	if Main.singleton.station: return
	if builder.picker.visible: return

	if Input.is_action_just_pressed("wheel_up"):
		inventory.change_focus(-1)

	if Input.is_action_just_pressed("wheel_down"):
		inventory.change_focus(1)

func use_selected_item():
	if inventory.current().has_item(Item.Id.Bomb):
		inventory.consume_one()
		throw(bomb_prefab)
	if inventory.current().has_item(Item.Id.HealthPotion):
		inventory.consume_one()
		heal(1)
	if inventory.current().has_item(Item.Id.EnergyPotion):
		inventory.consume_one()
		give_energy(5)
