extends Resource
class_name GameResources

enum ResourceType { GOLD, WOOD, FOOD, DEFAULT }
signal resources_changed(resource_type :ResourceType, has_grown :bool)

@export var gold :int:
	set(value):
		if value > 1000:
			return
		var prev_value = gold
		
		if gold != value:
			gold = calculate_new_resource_value(value)
			resources_changed.emit(ResourceType.GOLD, gold > prev_value)
@export var wood :int:
	set(value):
		if value > 1000:
			return
		var prev_value = wood
		
		if wood != value:
			wood =  calculate_new_resource_value(value)
			resources_changed.emit(ResourceType.WOOD, wood > prev_value)
@export var food :int:
	set(value):
		if value > 1000:
			return
		var prev_value = food
		
		if food != value:
			food = calculate_new_resource_value(value, food_limit)
			resources_changed.emit(ResourceType.FOOD, food < prev_value)
@export var food_limit :int = 30:
	set(value):
		var prev_value = food_limit
		
		food_limit = value
		resources_changed.emit(ResourceType.DEFAULT, food_limit > prev_value)

func calculate_new_resource_value(new_value :int, limit :int = 999) -> int:
	return clampi(new_value, 0, limit)
