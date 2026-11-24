class_name Rock extends Node2D

@export var poly: Polygon2D
@export var line: Line2D
@export var collider: CollisionPolygon2D
@export var tint: Color
@export var spot: Node2D

var mining := false
var life := 0
var timer := 0.0
var index_number := 0

func _ready() -> void:
	rotate(PI * randf_range(-2, 2))
	var changed = poly.polygon.duplicate()
	for i in changed.size():
		var diff = 50.0 if randf() < 0.8 else 100.0
		changed[i] += Vector2(randf_range(-diff, diff), randf_range(-diff, diff))
	poly.polygon = changed
	if randf() < 0.5:
		poly.polygon = Geometry2D.offset_polygon(poly.polygon, randf_range(-50, 100))[0]
	line.points = poly.polygon
	collider.polygon = poly.polygon
	poly.self_modulate = lerp(Color.WHITE, tint, randf())
	if Main.singleton.data.broken_nodes.has(index_number * 1.0):
		queue_free()

func _process(delta) -> void:
	timer -= delta
	if timer < 0: spot.hide()
	spot.rotate(delta * 10.0)

func mine(pos: Vector2):
	if spot.visible:
		if spot.global_position.distance_to(pos) > 75:
			spot.hide()
		else:
			timer = 1.0
			life -= 1
			strike(50 if life == 0 else 20)
			if life == 0:
				for i in 5:
					var p = Main.spawn_item(Item.Id.Rock, global_position)
					p.apply_impulse(Vector2.ONE.rotated(randf() * TAU) * 750)
				broke()
				queue_free()
				return
			get_tree().create_tween().tween_property(spot, "position", get_point(), 0.15).set_trans(Tween.TRANS_BOUNCE)
		return
	var distance = Main.singleton.bee.body.global_position.distance_to(pos)
	if distance > 300: return
	spot.position = get_point()
	spot.show()
	strike(20)
	life = 5
	timer = 1.0

func broke():
	if index_number >= 0:
		Main.singleton.data.broken_nodes.append(index_number)

func strike(amt: float):
	SoundEffects.singleton.add(37, spot.global_position, 0.7)
	Main.shake(amt, 0.2)
	Effects.singleton.add_many([1, 3], spot.global_position)

func get_point() -> Vector2:
	var i = randi_range(0, poly.polygon.size() - 1)
	return poly.polygon[i]
