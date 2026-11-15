class_name Dungeon extends Polygon2D

@export var spawn_spots: Array[Node2D]
@export var item_spots: Array[Node2D]

var spawners: Array[Node2D] = []

func populate(pos: Vector2, danger: PackedScene, item: PackedScene, chance: float):
	var parent = get_parent()
	for p in spawn_spots:
		if randf() > chance: continue
		var e = danger.instantiate() as Node2D
		e.global_position = p.global_position + pos
		e.rotation = p.rotation
		parent.add_child(e)
		spawners.append(e)
	for p in item_spots:
		var e = item.instantiate() as Node2D
		e.global_position = p.global_position + pos
		e.rotation = p.rotation
		parent.add_child(e)

func cleanup(checker: ShapeCast2D):
	for s in spawners:
		checker.global_position = s.global_position
		checker.force_shapecast_update()
		if not checker.is_colliding():
			s.queue_free()
