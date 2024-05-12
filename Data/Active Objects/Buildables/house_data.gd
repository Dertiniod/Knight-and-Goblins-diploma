extends BuildableObjectsData
class_name HouseData

@export var food_gain :int = 10

func add_food_to_limit():
	var game_resources :GameResources = GlobalData.get_game_resources()
	if game_resources:
		game_resources.food_limit += food_gain
