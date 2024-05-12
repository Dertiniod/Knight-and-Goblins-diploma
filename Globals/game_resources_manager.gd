extends Node

@onready var game_resources :GameResources = preload("res://Data/Resoruces/game_resources.tres")

signal resources_changed

func get_game_resources():
	if game_resources:
		return game_resources
	else:
		print("No available game resources found")
		return
	
func get_available_food():
	return game_resources.food_limit - game_resources.food
	
func can_buy(price_data :Resource) -> bool:
	var is_gold_enough = game_resources.gold >= price_data.get_cost("gold")
	var is_wood_enough = game_resources.wood >= price_data.get_cost("wood")
	
	var is_food_enough = game_resources.food_limit - game_resources.food >= price_data.get_cost("food")
	
	return is_gold_enough && is_food_enough && is_wood_enough

func buy(price_data :Resource) -> bool:
	if can_buy(price_data):
		game_resources.gold -= price_data.get_cost("gold")
		game_resources.wood -= price_data.get_cost("wood")
		
		game_resources.food += price_data.get_cost("food")
		return true
	else:
		return false

func _on_wave_completed(wave_data :WaveData):
	calculate_players_award(wave_data)

func calculate_players_award(wave_data :WaveData):
	# TODO :SOME REALLY DIFFICULT CALCULATIONS TO GIVE PLAYER A REWARD
	var additional_gold = wave_data.total_units * 50
	var additional_wood = wave_data.total_units * 10
	game_resources.gold += additional_gold
	game_resources.wood += additional_wood
	
	print("Player got reward for clearing the wave!")
	print("+", additional_gold, " +", additional_wood)
	print("")

func earn_wood(add_wood :int):
	game_resources.wood += add_wood

func earn_gold(add_income):
	game_resources.gold += add_income
