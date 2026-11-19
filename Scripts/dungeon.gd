class_name Dungeon extends Polygon2D

@export var spawn_spots: Array[Node2D]
@export var item_spots: Array[Node2D]

var spawners: Array[Node2D] = []
var egg: Node2D

func populate(pos: Vector2, danger: PackedScene, item: Item.Id, chance: float):
	var parent = get_parent()
	for p in spawn_spots:
		if randf() > chance: continue
		var e = danger.instantiate() as Node2D
		e.rotation = p.rotation
		e.global_position = p.position + pos
		spawners.append(e)
		parent.add_child(e)
	var p = item_spots.pick_random()
	egg = Main.singleton.item_db.spawn(item, pos + p.global_position)
	# e.gravity_scale = 0
	# e.global_position = p.global_position + pos
	# egg.rotation = p.rotation

func cleanup(checker: ShapeCast2D):
	for s in spawners:
		checker.global_position = s.global_position
		checker.force_shapecast_update()
		if not checker.is_colliding():
			s.queue_free()
