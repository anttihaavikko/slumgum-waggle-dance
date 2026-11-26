class_name Weapon extends Equipment

@export var area: ShapeCast2D
@export var damage := 3
@export var sparkles: Node2D
@export var sparks: Node2D

var deadly := false
var morphs := false
var deflects := false

func update(delta: float):
	var on_cooldown = cooldown > 0
	super.update(delta)
	align()
	if deadly:
		if area.is_colliding():
			var bird_hurt := false
			var worm_hurt := false
			var done: Array = []
			if area.is_colliding():
				for i in area.get_collision_count():
					var o = area.get_collider(i)
					done.append(o)
					if o is Breakable:
						o.destroy()
						deadly = false
					if o is RootPointer:
						deadly = false
						Effects.singleton.add(8, area.global_position)
						if o.root is Worm and not worm_hurt:
							worm_hurt = true
							o.root.hurt(damage)
						if o.root is Bird and not bird_hurt:
							bird_hurt = true
							o.root.hurt(damage)
					if morphs and o is Pickup:
						o.call_deferred("polymorph")
					if deflects and o is Spit:
						o.call_deferred("queue_free")

	if Input.is_action_just_pressed("primary") and not on_cooldown and can_swing():
		deadly = true
		SoundEffects.singleton.add(36, global_position, 0.7)
		await get_tree().create_timer(0.2).timeout
		deadly = false

func toggle(state: bool):
	super.toggle(state)
