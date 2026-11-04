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

func entered(_node: Node2D):
	var inventory = Main.singleton.inventory
	if inventory.can_add(item.data.item_id, item.amount):
		inventory.add_item(item.data.item_id, item.amount)
		queue_free()
