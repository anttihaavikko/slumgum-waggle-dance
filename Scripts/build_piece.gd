class_name BuildPiece extends Node2D

@export var body: StaticBody2D
@export var can_rotate := true
@export var connection_shapes: Array[ShapeCast2D]
@export var required_shape: ShapeCast2D
@export var takes_space := true
@export var label: RichTextLabel
@export var snap_points: Array[Node2D]
@export var sprite: Node2D
@export var extra_sprites: Array[Sprite2D]
@export var functionality: Node2D

var identifier: BuildPiece.Id
var data: PieceData
var placed := true
var can_break := true
var energized := false

enum Id {
	Platform,
	Support,
	Core,
	Box,
	Sign,
	Anvil,
	Jar,
	SpinningWheel,
	Banner,
	Bed,
	Dryer,
	LanternHanging,
	LanternStanding,
	TinkerTable,
	Pot,
	Cup
}

func can_place() -> bool:
	return is_attached() and not is_blocked()

func is_attached() -> bool:
	return connection_shapes.all(func(c: ShapeCast2D): return c.is_colliding()) if connection_shapes.size() > 0 else true

func is_blocked() -> bool:
	return required_shape.is_colliding() if takes_space and required_shape else false

func try_to_place():
	if not is_attached():
		Main.pop("NOT ATTACHED!")
		Main.shake(10, 0.1)
		return
	if is_blocked():
		Main.pop("BLOCKED!")
		Main.shake(10, 0.1)
		return
	await get_tree().create_timer(0.1).timeout
	energized = connection_shapes.any(is_colligin_with_energized)
	placed = true

func is_colligin_with_energized(shape: ShapeCast2D) -> bool:
	if shape.is_colliding():
		var p = shape.get_collider(0)
		if p is BuildPiece and p.energized:
			return true
	return false

func snap(points: Array[Node2D]):
	if Input.is_action_pressed("shift"): return
	var p := -1
	var best := -1
	var distance = 9999
	for i in snap_points.size():
		for j in points.size():
			var dist = snap_points[i].global_position.distance_to(points[j].global_position)
			if dist < distance:
				distance = dist
				p = i
				best = j
	if distance < 100:
		global_position = points[best].global_position - (snap_points[p].global_position - global_position)
