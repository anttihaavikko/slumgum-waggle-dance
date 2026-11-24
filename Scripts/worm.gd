class_name Worm extends Node2D

@export var head: RigidBody2D
@export var area: Area2D
@export var jaw_left: Node2D
@export var jaw_right: Node2D
@export var spit_spot: Node2D
@export var spit_prefab: PackedScene
@export var spit_effect: CPUParticles2D

var target: Node2D
var time := 0.0
var open := 0.0
var cooldown := 0.0
var life := 7

func _ready() -> void:
	head.apply_impulse(Vector2.RIGHT * 1000)
	area.body_entered.connect(entered)
	area.body_exited.connect(exited)

func hurt(amount: int):
	life -= amount
	SoundEffects.singleton.add(40, head.global_position, 1.5)
	if life <= 0:
		SoundEffects.singleton.add_many([38, 39], head.global_position, 2)
		Effects.singleton.add_many([7, 8], head.global_position)
		Effects.singleton.add_many([7, 8], (head.global_position + global_position) * 0.5)
		queue_free()

func spit():
	if cooldown > 0: return
	if target is BeeBody and not target.bee.health.is_alive(): return
	SoundEffects.singleton.add(15, head.global_position)
	spit_effect.emitting = true
	cooldown = 1.0
	var s = spit_prefab.instantiate() as Spit
	add_child(s)
	s.global_position = spit_spot.global_position
	s.dir = get_dir()
	head.apply_impulse(-s.dir * 2000)
	s.apply_impulse(s.dir * 2500)

func get_dir() -> Vector2:
	return Vector2.UP.rotated(head.global_rotation)

func _physics_process(delta: float) -> void:
	if global_position.distance_to(Main.bee_pos()) > 4000: return
	time += delta
	var dir = (target.global_position - global_position).normalized() if target else Vector2.UP.rotated(rotation)
	var mod = 1.0 + abs(sin(time))
	head.apply_force(dir * delta * 100000 * mod)
	var opening := 1 if target and is_looking() else -1
	open = clampf(open + delta * opening * 5.0, 0, 1)
	jaw_left.rotation = lerp_angle(0, -0.4, open)
	jaw_right.rotation = lerp_angle(0, 0.4, open)
	cooldown -= delta
	if open >= 1.0 and is_looking(0.15): spit()

func is_looking(thredhold := 0.8) -> bool:
	return abs((target.global_position - head.global_position).angle() + PI * 0.5 - head.global_rotation) < thredhold

func entered(node: Node2D):
	target = node

func exited(_node: Node2D):
	target = null
