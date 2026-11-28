class_name SaveData extends Object

var world_seed: int = randi()
var day := 1
var rank := 0
var time := 0.1
var x := 597.0
var y := -640.0
var tutorial_over := false
var health := 10
var inventory := []
var buildings := []
var seen := []
var built := []
var crafted := []
var explosions := []
var broken_nodes := []
var created_hats: Array[String] = []
var hat_parts: Array[String] = ["", "", ""]

static func load() -> SaveData:
	return Saver.new().load(func(): return SaveData.new()) as SaveData

func save():
	Saver.new().save(self)
