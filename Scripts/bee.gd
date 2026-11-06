class_name Bee extends Node2D

@export var body: RigidBody2D
@export var lander: RigidBody2D
@export var wings: AnimationPlayer
@export var inventory: Inventory
@export var tools: Array[Equipment]
@export var hands: Node2D
@export var health: HealthDisplay
@export var energy: HealthDisplay
@export var item: Sprite2D
@export var cam: Camera
@export var builder: Builder

var thrust = 1.5
var turning = 1.0
var energy_max := 30.0
var energy_left := energy_max
var charging := false
var landed := false
var zoomed := false

var current: Equipment

func _ready() -> void:
	Main.singleton.bee = self
	# global_position += Vector2.RIGHT * -500
	inventory.create_slots(4)
	for s in inventory.slots: s.in_bar = true
	# inventory.add_equipment(tools[Equipment.Type.Scythe])
	# inventory.add_equipment(tools[Equipment.Type.Hammer])
	inventory.add_equipment(tools[Equipment.Id.Brush])
	inventory.add_equipment(tools[Equipment.Id.Guitar])
	inventory.add_item(Item.Id.Nectar)
	inventory.add_item(Item.Id.Pollen)
	energy.max_hp = roundi(energy_max)
	await get_tree().process_frame
	inventory.focus(0)
	current_changed()
	inventory.changed.connect(current_changed)
	lander.body_entered.connect(land)
	lander.body_exited.connect(func(_o): landed = false)
	body.body_entered.connect(collide)

func is_holding(id: Equipment.Id):
	return current and current.identifier == id

func land(target: Node2D):
	landed = true
	charging = target is Platform
	cam.shake(body.linear_velocity.length() * 0.01, 0.12)
	# if charging:
	# 	Effects.singleton.pop("LANDED!", body.global_position)

func collide(_node: Node2D):
	var mag = body.linear_velocity.length()
	var threshold := 200.0
	if mag > threshold:
		var amt = roundi(mag / threshold)
		health.hurt(amt)
		cam.shake(amt * 5, 0.15)

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
			var z = 0.05 if zoomed else 0.3
			cam.zoom = Vector2.ONE * z

func _process(delta) -> void:
	if not health.is_alive(): return

	var rot = Input.get_axis("left", "right")
	var acc = Input.get_axis("accelerate", "brake") if energy_left > 0 else 0.0
	body.apply_torque(rot * delta * 5000000 * turning)
	body.apply_force(body.transform.y * acc * thrust * 100000 * delta)
	wings.speed_scale = 1.0 + absf(acc) * 3.0
	if abs(acc) > 0.01:
		change_energy(-delta)

	if landed:
		change_energy(delta * 5, energy_max if charging else 5.0)

	if current:
		current.update(delta)

	for i in 9:
		if Input.is_action_just_pressed("slot_%d" % [i + 1]) and i < inventory.slots.size():
			inventory.focus(i)

	if builder.held: return

	if Input.is_action_just_pressed("wheel_up"):
		inventory.change_focus(1)

	if Input.is_action_just_pressed("wheel_down"):
		inventory.change_focus(-1)
