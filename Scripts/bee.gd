class_name Bee extends Node2D

@export var body: RigidBody2D
@export var lander: RigidBody2D
@export var wings: AnimationPlayer
@export var inventory: Inventory
@export var tools: Array[Equipment]
@export var hands: Node2D

var thrust = 1.5
var turning = 1.0

var current: Equipment

func _ready() -> void:
	# global_position += Vector2.RIGHT * -500
	inventory.create_slots(5)
	inventory.add_equipment(tools[Equipment.Type.Scythe])
	inventory.add_equipment(tools[Equipment.Type.Hammer])
	inventory.focus(0)
	current_changed()
	inventory.changed.connect(current_changed)

func current_changed():
	current = inventory.current().equipment
	hands.visible = not current

func _process(delta) -> void:
	var rot = Input.get_axis("left", "right")
	var acc = Input.get_axis("accelerate", "brake")
	body.apply_torque(rot * delta * 5000000 * turning)
	body.apply_force(body.transform.y * acc * thrust * 100000 * delta)
	wings.speed_scale = 1.0 + absf(acc) * 3.0

	if current:
		current.update(delta)

	for i in 9:
		if Input.is_action_just_pressed("slot_%d" % [i + 1]) and i < inventory.slots.size():
			inventory.focus(i)
