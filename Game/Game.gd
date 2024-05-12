extends Node

@onready var main_menu_scene: PackedScene = preload("res://UI/main_menu.tscn")

var current_level
var current_level_data: LevelData

func _ready() -> void:
	game_init()
	GlobalSignals.return_to_main_menu_requested.connect(func(): return_to_main_menu())
	GlobalSignals.restart_game_requested.connect(_on_restart_game_requested)
	
func game_init():
	current_level = main_menu_scene.instantiate()
	add_child(current_level)
	
	current_level.level_chosen.connect(_on_level_chosen)

	
func _on_restart_game_requested():
	return_to_main_menu()
	switch_level(null, current_level_data)
	
func _on_main_menu_called(caller):
	pass
	
func _on_level_chosen(menu, level_data):
	switch_level(menu, level_data)

func switch_level(menu, level_data :LevelData):
	if level_data:
		current_level_data = level_data
	
	var level_path = level_data.scene_path
	var level_scene = load(level_path)
	
	if is_instance_valid(current_level):
		current_level.queue_free()
	
	current_level = level_scene.instantiate()
	add_child(current_level)
	
func return_to_main_menu():
	current_level.queue_free()
	current_level = null
	game_init()
