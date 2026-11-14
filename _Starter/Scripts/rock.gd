class_name Rock extends Node2D

@export var poly: Polygon2D
@export var line: Line2D
@export var collider: CollisionPolygon2D
@export var tint: Color
@export var spot: Node2D

var mining := false
var life := 0
var timer := 0.0

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

func _process(delta) -> void:
	timer -= delta
	if timer < 0: spot.hide()
	spot.rotate(delta * 10.0)

func mine(pos: Vector2):
	if spot.visible:
		if spot.global_position.distance_to(pos) > 50:
			spot.hide()
		else:
			timer = 1.0
			life -= 1
			if life == 0:
				Main.shake(50, 0.2)
				Effects.singleton.add_many([1, 3], global_position)
				for i in 5:
					var p = Main.spawn_item(Item.Id.Rock, global_position)
					p.apply_impulse(Vector2.ONE.rotated(randf() * TAU) * 750)
				queue_free()
				return
			get_tree().create_tween().tween_property(spot, "position", get_point(), 0.15).set_trans(Tween.TRANS_BOUNCE)
		return
	var distance = Main.singleton.bee.body.global_position.distance_to(pos)
	if distance > 300: return
	Main.shake(0.3, 0.2)
	spot.position = get_point()
	spot.show()
	life = 5
	timer = 1.0

func get_point() -> Vector2:
	var i = randi_range(0, poly.polygon.size() - 1)
	return poly.polygon[i]
