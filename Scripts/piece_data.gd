class_name PieceData extends Resource

@export var title: String
@export_multiline var description: String
@export var prefab: PackedScene
@export var sprite: Texture2D
@export var recipe: Dictionary[Item.Id, int]
