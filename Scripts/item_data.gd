class_name ItemData extends Resource

@export var item_id: Item.Id
@export var stack_size := 20
@export var title: String
@export var color: Color = Color.WHITE
@export var sprite: Texture2D
@export_multiline var description: String
@export var recipe: Dictionary[Item.Id, int]
@export var recipe_creates := 1
@export var hold_offset := 0.0
