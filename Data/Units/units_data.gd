extends Resource
class_name UnitData

enum UnitTeam { knights, goblins }

@export_group("General")
@export var name :String
@export var unit_team :UnitTeam:
	set(value):
		if value == UnitTeam.knights:
			ally_group_name = "knights"
			enemy_group_name = "goblins"
		elif value == UnitTeam.goblins:
			ally_group_name = "goblins"
			enemy_group_name = "knights"
@export_multiline var description :String

@export_group("Attributes")
@export var health :int
@export var spawn_time :int:
	set(value):
		if value <= 0:
			value = 1
		spawn_time = value

@export_group("Price")
@export var gold :int = 0
@export var food :int = 0
@export var wood :int = 0

@export_group("Path")
@export var scene_path :String

var ally_group_name :String
var enemy_group_name :String
var cost_data :Cost

func initialize_data() -> void:
	cost_data = Cost.new()
	
	cost_data.set_cost("gold", gold)
	cost_data.set_cost("food", food)
	cost_data.set_cost("wood", wood)

func get_cost(resource_name :String) -> int:
	return cost_data.get_cost(resource_name)
