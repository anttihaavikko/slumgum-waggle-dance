class_name SaveData extends Object

var world_seed: int = randi()
var day := 0
var rank := 0
var time := 0.1
var x: float
var y: float
var tutorial_over := false
var health := 10
var inventory := []
var buildings := []
var seen := []
var built := []
var crafted := []

static func load() -> SaveData:
	return Saver.new().load(func(): return SaveData.new()) as SaveData

func save():
	Saver.new().save(self)
