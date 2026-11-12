class_name ItemManager extends Node

@export var items: Array[ItemData]
@export var pickup_prefab: PackedScene

func spawn(id: Item.Id, pos: Vector2, amount: int = 1, equipment: Equipment.Id = Equipment.Id.Brush):
	var pickup = pickup_prefab.instantiate() as Pickup
	pickup.item = Item.new(items[id], amount)
	pickup.item.equip = equipment
	pickup.global_position = pos
	call_deferred("add_child", pickup)
	return pickup
