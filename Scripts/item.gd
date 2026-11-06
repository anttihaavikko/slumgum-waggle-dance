class_name Item

enum Id {
	Nectar,
	Pollen,
	Wax,
	Honey,
	Equipment
}

var data: ItemData
var amount: int
var equip: Equipment.Id

func _init(dat: ItemData, amt: int = 1) -> void:
	data = dat
	amount = amt
