class_name Bee extends Node2D

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
@export var pendulum_base: Node2D
@export var pendilum: Node2D

var thrust = 1.5
var turning = 1.0
var energy_max := 20.0
var energy_left := energy_max
var charging := false
var landed := false
var zoomed := false
var dead := false
var stretch := 0.0

var current: Equipment

func _ready() -> void:
	Main.singleton.bee = self
	# global_position += Vector2.RIGHT * -500
	inventory.create_slots(7)
	for s in inventory.slots:
		s.in_bar = true
		s.show_key(str(inventory.slots.find(s) + 1))
	energy.max_hp = roundi(energy_max)
	await get_tree().process_frame
	inventory.focus(0)
	current_changed()
	inventory.changed.connect(current_changed)
	lander.body_entered.connect(land)
	lander.body_exited.connect(func(_o): landed = false)
	body.body_entered.connect(collide)
	inventory.announces = true
	# await get_tree().create_timer(1).timeout
	# inventory.add_item(Item.Id.Wax, 20)
	await get_tree().process_frame
	# inventory.add_equipment(tools[Equipment.Id.Scythe])
	if OS.is_debug_build():
		inventory.add_equipment(tools[Equipment.Id.Hammer])
		inventory.add_equipment(tools[Equipment.Id.Guitar])
		# inventory.add_equipment(tools[Equipment.Id.Pickaxe])
		# inventory.add_equipment(tools[Equipment.Id.Paintbrush])
		# inventory.add_equipment(tools[Equipment.Id.Brush])
		# inventory.add_equipment(tools[Equipment.Id.Lantern])
		inventory.add_item(Item.Id.Nectar, 20)
		# inventory.add_item(Item.Id.String, 20)
		# inventory.add_item(Item.Id.Resin, 20)
		# inventory.add_item(Item.Id.Acid, 20)
		# inventory.add_item(Item.Id.Wax, 20)
		# inventory.add_item(Item.Id.Pollen, 10)
		# inventory.add_item(Item.Id.Bomb, 10)

func throw(prefab: PackedScene):
	var obj = prefab.instantiate() as RigidBody2D
	obj.position = body.position
	var dir = get_global_mouse_position() - body.global_position
	add_child(obj)
	obj.apply_impulse(dir.normalized() * 1500)

func can_open() -> bool:
	return not current or not current.blocks_clicks()

func energy_for_life():
	energy_left = energy_max
	energy.heal(999)
	damage(1)

func die():
	health.hurt(999)
	for i in inventory.slots:
		if not i.equipment:
			var p = i.drop()
			if p: p.apply_impulse(Vector2.UP.rotated(randf_range(0, 2 * PI)) * 800)
	face.left_eye.hide()
	face.right_eye.hide()
	crosses.show()
	hands.hide()
	if current: current.hide()
	wings.stop()
	face.mouth.scale.y *= -1
	item.hide()
	await get_tree().create_timer(3).timeout
	body.move_to(global_position, 0)
	lander.move_to(global_position + Vector2.DOWN * 133, 0)
	body.linear_velocity = Vector2.ZERO
	body.angular_velocity = 0
	lander.linear_velocity = Vector2.ZERO
	lander.angular_velocity = 0
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

func is_holding(id: Equipment.Id):
	return current and current.identifier == id

func danger():
	if randf() > 0.01 * Main.singleton.rank: return
	Main.singleton.call_deferred("spawn_bird")

func land(target: Node2D):
	landed = true
	charging = target is Platform
	cam.shake(body.linear_velocity.length() * 0.01, 0.12)
	# stretch -= body.linear_velocity.y * 0.0002
	if not charging and energy.hp < 5 and not dead:
		danger()

func collide(_node: Node2D):
	var mag = body.linear_velocity.length()
	var threshold := 200.0
	if mag > threshold:
		var amt = roundi(mag / threshold)
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

func change_energy(dir: float, limit: float = energy_max):
	if limit < energy_max and energy_left > limit and dir > 0: return
	energy_left = clampf(energy_left + dir, 0, energy_max)
	energy.hp = roundi(energy_left)

func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.is_debug_build(): return

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_Z:
			zoomed = not zoomed
			var z = 0.025 if zoomed else 0.3
			cam.zoom = Vector2.ONE * z

func _process(delta) -> void:
	var limit := 10.0
	var look_mod = (limit - clamp(body.linear_velocity.length(), 0, limit)) / limit
	cam.position = Vector2.ZERO.move_toward(body.get_local_mouse_position(), 300 * look_mod) + \
		body.linear_velocity * 0.5

	if builder.held:
		cam.position = Vector2.ZERO

	var rot = Input.get_axis("left", "right")
	var acc = Input.get_axis("accelerate", "brake") if energy_left > 0 else 0.0
	var speed = 10.0 if OS.is_debug_build() and Input.is_action_pressed("shift") else 1.0
	if health.is_alive():
		body.apply_torque(rot * delta * 5000000 * turning)
		body.apply_force(body.transform.y * acc * thrust * 100000 * delta * speed)
		wings.speed_scale = 1.0 + absf(acc) * 3.0
		if abs(acc) > 0.01:
			change_energy(-delta)

	# stretch -= clamp(signf(stretch) * delta * 0.5, -abs(stretch), abs(stretch))
	var diff = pendulum_base.global_position - pendilum.global_position
	stretch = diff.y * 0.004 - diff.x * 0.004
	stretch = clamp(stretch, -0.2, 0.2)
	visuals.scale = Vector2(1 - stretch, 1 + stretch)
	leg_container.scale = visuals.scale

	if not health.is_alive(): return

	if landed:
		change_energy(delta * 5, energy_max if charging else 5.0)

	if current:
		current.update(delta)

	for i in 9:
		if Input.is_action_just_pressed("slot_%d" % [i + 1]) and i < inventory.slots.size():
			inventory.focus(i)

	if Input.is_action_just_pressed("primary"):
		if inventory.current().has_item(Item.Id.Bomb):
			throw(bomb_prefab)

	if builder.held and builder.held.can_rotate: return
	if Main.singleton.station: return
	if builder.picker.visible: return

	if Input.is_action_just_pressed("wheel_up"):
		inventory.change_focus(-1)

	if Input.is_action_just_pressed("wheel_down"):
		inventory.change_focus(1)
