class_name Rock extends Node2D

@export var poly: Polygon2D
@export var line: Line2D
@export var collider: CollisionPolygon2D
@export var tint: Color
@export var spot: Node2D
@export var key: Sprite2D
@export var key_alt: Sprite2D
@export var key_sprites: Array[Texture2D]

var mining := false
var life := 0
var timer := 0.0
var index_number := 0
var default_key: Texture2D
var required_key := -1
var key_actions := ["interact", "cancel", "hover", "toggle_tooltip", "shift", "middle"]

func _ready() -> void:
	default_key = key.texture
	rotate(PI * randf_range(-2, 2))
	key.rotate(-rotation)
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
	if timer < 0:
		spot.hide()
		key.hide()
		required_key = -1
	spot.rotate(delta * 10.0)

	if required_key >= 0:
		if Input.is_action_just_pressed(key_actions[required_key]):
			Main.singleton.bee.swinger.swing()
			mine(spot.global_position)
			return
		for a in key_actions:
			if Input.is_action_just_pressed(a):
				mine(spot.global_position + Vector2.ONE * 100)

func mine(pos: Vector2):
	if spot.visible:
		if spot.global_position.distance_to(pos) > 75:
			spot.hide()
			key.hide()
			required_key = -1
			SoundEffects.singleton.add(10, Main.bee_pos())
		else:
			timer = 1.0
			life -= 1
			strike(50 if life == 0 else 20)
			if life == 0:
				for i in 5:
					var pp = Main.spawn_item(Item.Id.Rock, global_position)
					pp.apply_impulse(Vector2.ONE.rotated(randf() * TAU) * 750)
				broke()
				SoundEffects.singleton.add(38, global_position)
				queue_free()
				return
			var p = get_point()
			get_tree().create_tween().tween_property(spot, "position", p, 0.15).set_trans(Tween.TRANS_BOUNCE)
			get_tree().create_tween().tween_property(key, "position", get_key_offset(p), 0.15).set_trans(Tween.TRANS_BOUNCE)
			change_key()
		return
	var distance = Main.singleton.bee.body.global_position.distance_to(pos)
	if distance > 300: return
	spot.position = get_point()
	key.position = get_key_offset(spot.position)
	spot.show()
	key.show()
	change_key()
	strike(20)
	life = 5
	timer = 1.0

func change_key():
	required_key = randi_range(0, key_sprites.size() - 1)
	var pad := Main.singleton.input_detection.using_pad
	key.texture = default_key if not pad else key_sprites[required_key]
	key_alt.texture = key.texture
	key.scale = (1.25 if pad else 1.0) * Vector2.ONE
	if pad and required_key > 3: key.scale = Vector2.ONE * 0.7

func get_key_offset(pos: Vector2) -> Vector2:
	return pos + pos.normalized() * 250

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
