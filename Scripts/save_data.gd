class_name SaveData extends Object

var world_seed: int = randi()
var day := 0
var rank := 0
var time := 0.1
var x := 597.0
var y := -240.0
var tutorial_over := false
var health := 10
var inventory := []
var buildings := []
var seen := []
var built := []
var crafted := []
var explosions := []
var broken_nodes := []

static func load() -> SaveData:
	return Saver.new().load(func(): return SaveData.new()) as SaveData

func save():
	Saver.new().save(self)
