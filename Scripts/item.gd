class_name Item

enum Id {
	Nectar,
	Pollen,
	Wax,
	Honey,
	Equipment,
	Cloth,
	Bomb,
	EnergyPotion,
	HealthPotion,
	Resin,
	Seed,
	Rock,
	PaintRed,
	PaintGreen,
	PaintWhite,
	PaintYellow,
	Dirt,
	Sand,
	Fiber,
	String,
	Acid,
	GoldSeed,
	PureSeed,
	Egg
}

var data: ItemData
var amount: int
var equip: Equipment.Id

func _init(dat: ItemData, amt: int = 1) -> void:
	data = dat
	amount = amt


static func can_make(recipe: Dictionary[Id, int], with: Array[Id]) -> bool:
	for id in recipe.keys():
		if not with.has(id):
			return false
	return true
