class_name HatPart extends Resource

@export var title: String
@export_multiline var description: String
@export var slot: int
@export var color: Color = Color.WHITE
@export var sprite: Texture2D
@export var recipe: Dictionary[Item.Id, int]
@export var offset: Vector2

func sort_key() -> String:
	return "%d-%s" % [slot, title]
