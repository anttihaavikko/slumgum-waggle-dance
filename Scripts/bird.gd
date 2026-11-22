class_name Bird extends Node2D

@export var body: RigidBody2D
@export var head: RigidBody2D
@export var beak: RigidBody2D
@export var swipe_right: Area2D
@export var swipe_left: Area2D
@export var main_sprites: Array[Node2D]
@export var stripe: Polygon2D
@export var chest: Node2D
@export var beak_sprite: Node2D
@export var blush: Node2D
@export var themes: Array[BirdTheme]

var time := 0.0
var target: Node2D
var max_life := 25
var life := max_life
var leaving := false

func _ready() -> void:
	target = Main.singleton.bee.body
	swipe_left.body_entered.connect(swipe_to_left)
	swipe_right.body_entered.connect(swipe_to_right)
	colorize()
	await get_tree().create_timer(28).timeout
	if life == max_life: leave()

func colorize():
	var theme = themes.pick_random()
	for s in main_sprites: s.self_modulate = theme.main
	stripe.self_modulate = theme.stripe
	chest.self_modulate = theme.chest
	beak_sprite.self_modulate = theme.beak
	blush.modulate = theme.cheeks

func _process(delta: float) -> void:
	var dead = not target or not Main.singleton.bee.health.is_alive()
	time += delta * 5.0
	body.apply_force(Vector2.UP * 2000000 * delta * (sin(time) + 1) * (2 if dead else 1))
	if target and not dead:
		var dir = (target.global_position - beak.global_position).normalized()
		beak.apply_force(dir * 20000 * (sin(time) + 1))
	else:
		leave()

func leave():
	if leaving: return
	leaving = true
	target = null
	await get_tree().create_timer(1).timeout
	Music.bird_attack(false)
	await get_tree().create_timer(9).timeout
	Main.singleton.remove_bird(self)
	queue_free()

func swipe_to_left(_body: Node2D):
	swipe(1)

func swipe_to_right(_body: Node2D):
	swipe(-1)

func swipe(dir: float):
	beak.apply_torque_impulse(dir * 10000000)

func hurt(amount: int):
	life -= amount
	if life <= 0:
		Effects.singleton.add_many([1, 7, 8], body.global_position)
		Main.shake(80, 0.3)
		Main.singleton.remove_bird(self)
		Music.bird_attack(false)
		queue_free()
