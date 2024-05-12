extends Control
class_name World

@export var world_data :WorldData
@export var menu :MainMenu

@onready var container: Control = $Container

var level_containers_array :Array[Node]
var level_buttons_array :Array[LevelButton]

func _ready() -> void:
	level_containers_array = container.get_children()
	
	for container in level_containers_array:
		var level_button = container.get_child(1)
		if container.get_child(1) is LevelButton:
			level_button.level_button_pressed.connect(_on_level_button_pressed)
			level_buttons_array.push_back(level_button)
	init_level_buttons()

func init_level_buttons():
	var world_size :int = world_data.levels_amount
	
	if world_size != level_buttons_array.size():
		world_size = level_buttons_array.size()
	
	for i in world_size:
		level_buttons_array[i].update_stars(world_data.levels_info[i])

func _on_level_button_pressed(level_data :LevelData):
	menu.level_chosen.emit(menu, level_data)
