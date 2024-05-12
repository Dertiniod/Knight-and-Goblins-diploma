extends ActiveObjectsData
class_name BuildableObjectsData

@export var gold :int
@export var food :int
@export var wood :int

@export var building_time :float

var cost_data :Cost

func initialize_data() -> void:
	set_cost()

func set_cost():
	cost_data = Cost.new()
	
	cost_data.set_cost("gold", gold)
	cost_data.set_cost("food", food)
	cost_data.set_cost("wood", wood)

func get_cost(resource_name :String) -> int:
	return cost_data.get_cost(resource_name)
