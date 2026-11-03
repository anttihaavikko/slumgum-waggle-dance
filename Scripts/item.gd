class_name Item

enum Id {
	Nectar,
	Pollen,
	Wax,
	Honey
}

var data: ItemData
var amount: int

func _init(dat: ItemData, amt: int = 1) -> void:
	data = dat
	amount = amt
