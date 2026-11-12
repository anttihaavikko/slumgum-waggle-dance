class_name Spit extends RigidBody2D

var dir := Vector2.ZERO

func _ready() -> void:
	body_entered.connect(enter, CONNECT_ONE_SHOT)

func enter(target: Node):
	if target is BeeBody:
		target.apply_impulse(dir.normalized() * 1000)
	else:
		Main.spawn_item(Item.Id.Nectar, global_position)
	Effects.singleton.add_many([3], global_position)
	queue_free()
