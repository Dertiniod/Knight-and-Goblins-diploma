extends Node
class_name Level

signal wave_changed(wave_data :WaveData)
signal wave_started(wave_data :WaveData)
signal wave_cleared(wave_data :WaveData)
signal level_completed(wave_data :WaveData)
signal level_failed(wave_data :WaveData)
signal gold_mine_destroyed(gold_mines_count :int)

@export var preparation_time_array :Array[float]
@export var level_data :LevelData

@onready var knights_folder: Node2D = %Knights
@onready var goblins_folder: Node2D = %Goblins
@onready var nav_folder: Node = %NavigationNodes
@onready var wave_timer: Timer = %WaveTimer
@onready var level_introduction_node: Path2D = $LevelIntroduction

@onready var ai_controller: AIController = $AIController
@onready var player_controller: PlayerController = $PlayerController
@onready var gold_mines: Array[Node] = %GoldMines.get_children()
@onready var level_introduction_camera_scene :PackedScene = preload("res://level_introduction_camera.tscn")

@export var level_number :int = 1
@export var total_wave_amount :int = 2

var wave_data :WaveData
var gold_mines_count :int
var current_wave_number :int = 1:
	set(value):
		current_wave_number = value
		if is_instance_valid(wave_data):
			wave_data.wave_number = current_wave_number
var game_resources :GameResources

func _ready() -> void:
	var level_introduction_camera :PathFollow2D = level_introduction_camera_scene.instantiate()
	level_introduction_camera.path2D = level_introduction_node
	level_introduction_node.add_child(level_introduction_camera)
	
	GlobalSignals.level_introduction_finished.connect(_on_level_started)

func _process(delta: float) -> void:
	if !wave_timer.is_stopped():
		player_controller.update_preparation_time(get_preparation_time_left())

func _on_level_started(new_camera_position :Vector2):
	player_controller.init_player_camera(new_camera_position)
	start_level()

func start_level():
	player_controller.initialize_controller()
	ai_controller.initialize_controller()
	
	get_tree().paused = false
	
	await get_tree().create_timer(2.5).timeout
	
	game_resources = GlobalData.get_game_resources()
	wave_cleared.connect(GameResourcesManager._on_wave_completed)
	
	for gold_mine in gold_mines:
		if gold_mine is GoldMine:
			gold_mines_count += 1
			gold_mine.object_destroyed.connect(_on_gold_mine_destroyed)
	
	player_controller.hud.set_wave_limit(total_wave_amount)
	
	# If we added more ways info than there are total waves - clear those values out.
	if preparation_time_array.size() > total_wave_amount:
		preparation_time_array.resize(total_wave_amount)
	else:
		print("Prepartion Time Array doesn't have value for one or more waves. Called on - ", name)
		get_tree().quit()
	
	# When AI Controller has no more units controlled - getting the signal to finish the wave.
	ai_controller.no_controlled_units_remain.connect(_on_ai_units_ended)
	
	wave_changed.connect(player_controller._on_wave_changed)
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	
	# TODO: Find out the way to find appropriate time for each wave
	start_wave_preparation(get_wave_preparation_time())

func get_wave_preparation_time():
	var wave_index = current_wave_number - 1
	
	if wave_index < 0 or wave_index > total_wave_amount:
		print("Error. Something went wrong with wave preparation time array.")
		get_tree().quit()
	return preparation_time_array[wave_index]

func get_preparation_time_left():
	var time_left = wave_timer.time_left
	var minutes = floor(time_left / 60)
	var seconds = int(time_left) % 60
	return Vector2(minutes, seconds)

func start_wave_preparation(preparation_time :float):
	wave_timer.stop()
	
	wave_timer.wait_time = preparation_time
	wave_timer.start()
	GlobalSignals.wave_preparation_started.emit()

func finish_wave():
	if current_wave_number == total_wave_amount:
		GlobalSignals.game_won.emit()
		
		if is_instance_valid(wave_data):
			level_completed.emit(wave_data)
		return
	
	wave_cleared.emit(wave_data)
	current_wave_number += 1
	
	start_wave_preparation(get_wave_preparation_time())

func get_folder_for_unit_type(group_name :String) -> Node2D:
	match group_name:
		"knights":
			return knights_folder
		"goblins":
			return goblins_folder
	return null

func get_nav_folder():
	if nav_folder != null:
		return nav_folder

func spawn_wave():
	ai_controller.create_wave(calculate_wave())
	wave_timer.stop()

func calculate_wave():
	wave_data = WaveData.new() as WaveData
	
	if current_wave_number != 1:
		apply_buffs()
		
		var base_units_amount : int = wave_data.total_units
		var additional_units_per_wave : int = min(4, int(current_wave_number * 0.5))
		var additional_units_per_level : int = int(level_number * 2)
		
		wave_data.total_units = base_units_amount + additional_units_per_wave + additional_units_per_level
	
	for i in wave_data.total_units:
		var next_unit_type_to_spawn :UnitData = get_unit_type_to_spawn()
		wave_data.units_data.push_back(next_unit_type_to_spawn)
	
	wave_changed.emit(current_wave_number)
	wave_data.wave_number = current_wave_number
	
	GlobalSignals.wave_started.emit(wave_data)
	return wave_data

func get_unit_type_to_spawn() -> UnitData:
	# TODO: Choose the type of enemy based on their strength, current level and wave.
	return GlobalData.goblins_data[0]

func apply_buffs():
	var goblin_unit_types :Array[UnitData] = GlobalData.goblins_data as Array[UnitData]
	
	for unit_type in goblin_unit_types:
		print(unit_type.name, " just got a buff, new stats = attack - ", unit_type.damage, " health - ", unit_type.health, " attack speed - ", unit_type.attack_speed, " spawn_time - ", unit_type.spawn_time)
		unit_type.apply_buff(current_wave_number, level_number)

# SIGNALS
func _on_gold_mine_destroyed(destroyed_mine :GoldMine):
	gold_mines_count -= 1
	gold_mine_destroyed.emit(gold_mines_count)
	
	if gold_mines_count <= 0:
		GlobalSignals.game_lost.emit()
		
		level_failed.emit()

func _on_ai_units_ended():
	finish_wave()

func _on_wave_timer_timeout():
	GlobalSignals.wave_preparation_finished.emit()
	spawn_wave()
