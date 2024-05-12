extends Node

@export var goblins_data :Array[UnitData]
@export var knights_data :Array[UnitData]

var game_resources :GameResources = preload("res://Data/Resoruces/game_resources.tres")

var player_controller: PlayerController

func get_player_controller():
	return player_controller

func set_player_controller(controller :PlayerController):
	player_controller = controller

func get_game_resources():
	var game_res :GameResources = player_controller.game_resources
	return game_resources
