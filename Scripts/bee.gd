class_name Bee extends Node2D

@export var body: RigidBody2D
@export var lander: RigidBody2D
@export var wings: AnimationPlayer
@export var inventory: Inventory
@export var tools: Array[Equipment]
@export var hands: Node2D
@export var health: HealthDisplay
@export var energy: HealthDisplay

var thrust = 1.5
var turning = 1.0
var energy_max := 30.0
var energy_left := energy_max

var current: Equipment

func _ready() -> void:
	# global_position += Vector2.RIGHT * -500
	inventory.create_slots(5)
	inventory.add_equipment(tools[Equipment.Type.Scythe])
	inventory.add_equipment(tools[Equipment.Type.Hammer])
	inventory.focus(0)
	current_changed()
	inventory.changed.connect(current_changed)
	energy.max_hp = roundi(energy_max)

func current_changed():
	current = inventory.current().equipment
	hands.visible = not current

func _process(delta) -> void:
	var rot = Input.get_axis("left", "right")
	var acc = Input.get_axis("accelerate", "brake") if energy_left > 0 else 0.0
	body.apply_torque(rot * delta * 5000000 * turning)
	body.apply_force(body.transform.y * acc * thrust * 100000 * delta)
	wings.speed_scale = 1.0 + absf(acc) * 3.0
	if abs(acc) > 0.01:
		energy_left = clampf(energy_left - delta, 0, energy_max)
		energy.hp = roundi(energy_left)

	if current:
		current.update(delta)

	for i in 9:
		if Input.is_action_just_pressed("slot_%d" % [i + 1]) and i < inventory.slots.size():
			inventory.focus(i)
