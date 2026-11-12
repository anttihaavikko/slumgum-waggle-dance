@abstract class_name Equipment extends Node2D

enum Id {
	Hammer,
	Scythe,
	Brush,
	Guitar,
	Paintbrush,
	Lantern
}

@export var identifier: Id
@export_multiline var description: String
@export var swinger: Swinger
@export var aligner: Node2D
@export var swing_dir := 1.0
@export var sprite: Sprite2D
@export var flips := false
@export var aligns := true

var cooldown := 0.0

func blocks_clicks() -> bool:
	return false

func update(_delta: float):
	cooldown -= _delta
	if cooldown > 0: return
	if swinger and Input.is_action_just_pressed("primary"):
		swinger.swing(swing_dir)
		cooldown = 0.2

func toggle(state: bool):
	visible = state

func align():
	var mp = get_global_mouse_position()
	if aligner: aligner.look_at(mp)
	if not aligns: aligner.rotation = 0
	if flips: sprite.flip_v = mp.x < global_position.x
