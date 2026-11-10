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
	Sand
}

var data: ItemData
var amount: int
var equip: Equipment.Id

func _init(dat: ItemData, amt: int = 1) -> void:
	data = dat
	amount = amt
