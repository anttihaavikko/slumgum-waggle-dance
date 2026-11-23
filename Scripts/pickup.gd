class_name Pickup extends RigidBody2D

@export var sprite: Sprite2D
@export var area: Area2D

var item: Item:
	set(val):
		item = val
		sprite.texture = item.data.sprite
		sprite.self_modulate = item.data.color

func _ready() -> void:
	area.body_entered.connect(entered)
	body_entered.connect(collided)

func collided(_node: Node2D):
	if global_position.distance_to(Main.bee_pos()) > 1000: return
	var limit := 200.0
	if linear_velocity.length() > limit:
		var amt = roundf(linear_velocity.length() / limit)
		SoundEffects.singleton.add(17, global_position, min(amt * 0.5, 1.5))

func entered(_node: Node2D):
	if not Main.singleton.bee.health.is_alive(): return
	if not item: return
	var inventory = Main.singleton.inventory
	if inventory.can_add(item.data.item_id, item.amount):
		if item.data.item_id == Item.Id.Equipment:
			inventory.add_equipment(Main.singleton.bee.tools[item.equip])
		else:
			inventory.add_item(item.data.item_id, item.amount)
		queue_free()

func launch(force: float = 1.0):
	await get_tree().process_frame
	apply_impulse(Vector2.ONE.rotated(randf() * TAU) * 200 * force)
	apply_torque_impulse(randf() * 30 * force)
