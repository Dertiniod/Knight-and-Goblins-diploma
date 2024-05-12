extends Resource
class_name Cost

@export var cost_dic :Dictionary

func set_cost(resource_name :String, new_cost :int):
	cost_dic[resource_name] = new_cost
	
func get_cost(resource_name :String) -> int:
	return cost_dic[resource_name]
