class_name BuildPiece extends Node2D

@export var identifier: BuildPiece.Id
@export var body: StaticBody2D
@export var can_rotate := true
@export var connection_shapes: Array[ShapeCast2D]
@export var required_shape: ShapeCast2D
@export var takes_space := true
@export var label: RichTextLabel
@export var snap_points: Array[Node2D]
@export var sprite: Node2D

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
	LanternStanding
}

func can_place() -> bool:
	return is_attached() and not is_blocked()

func is_attached() -> bool:
	return connection_shapes.all(func(c: ShapeCast2D): return c.is_colliding()) if connection_shapes.size() > 0 else true

func is_blocked() -> bool:
	return required_shape.is_colliding() if takes_space and required_shape else false

func try_to_place():
	if not is_attached():
		Main.pop("Not attached!")
		return
	if is_blocked():
		Main.pop("Blocked!")
		return

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
