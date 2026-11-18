class_name HealthDisplay extends Control

@export var max_hp := 10:
	set(val):
		max_hp = val
		update_shown()
@export var label: RichTextLabel
@export var max_label: RichTextLabel
@export var bar: Control
@export var full_scale: Vector2 = Vector2(1, 1)
@export var empty_scale: Vector2 = Vector2(0, 1)
@export var animated := true

var hp: int:
	set(val):
		hp = val
		update_shown()

func _ready() -> void:
	hp = max_hp

func hurt(amount: int) -> void:
	hp = max(hp - amount, 0)

func heal(amount: int) -> void:
	hp = min(hp + amount, max_hp)

func is_alive() -> bool:
	return hp > 0

func is_full() -> bool:
	return hp == max_hp

func update_shown() -> void:
	if label:
		if max_label:
			label.text = "%d" % [hp]
			max_label.text = "%d" % [max_hp]
		else:
			label.text = "%d/%d" % [hp, max_hp]
	if bar:
		var target = lerp(empty_scale, full_scale, clampf(hp * 1.0 / max_hp, 0, 1))
		if animated:
			get_tree().create_tween().tween_property(bar, "scale", target, 0.1).set_trans(Tween.TRANS_QUAD)
		else:
			bar.scale = target
