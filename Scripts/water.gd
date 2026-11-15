extends Polygon2D

@export var area: Area2D

func _ready() -> void:
	area.body_entered.connect(enter)

func enter(node: Node2D):
	Effects.singleton.add(3, node.global_position)
	if node is BeeBody and Main.singleton.bee.health.is_alive():
		Main.singleton.bee.die()
