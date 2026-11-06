@abstract class_name Equipment extends Node2D

enum Id {
	Hammer,
	Scythe,
	Brush,
	Guitar
}

@export var identifier: Id
@export var swinger: Swinger
@export var aligner: Node2D
@export var swing_dir := 1.0

func update(_delta: float):
	if swinger and Input.is_action_just_pressed("primary"):
		swinger.swing(swing_dir)

func toggle(state: bool):
	visible = state

func align():
	var mp = get_global_mouse_position()
	if aligner: aligner.look_at(mp)
