extends RigidBody2D

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	for island in Main.singleton.islands:
		island.explode(island.to_local(global_position))
	Main.shake(40, 0.3)
	queue_free()
