extends Node
class_name SpawnComponent

signal unit_is_being_trained(is_being_trained :bool)
signal new_unit_spawned(unit :Unit)

@onready var spawn_timer: Timer = $Timer

var units_queue :Array[UnitData]
var unit_data :UnitData

# TODO: Move all spawn_menu functionality to player_controller
var spawn_menu :CanvasLayer

var level :Level
var controller :Controller
var spawn_point :Node2D

var unit_being_spawned: bool = false

func _ready() -> void:
	controller = get_parent() as Controller
	spawn_timer.connect("timeout", _on_timer_timeout)

func _process(delta: float) -> void:
	if not controller is PlayerController or !spawn_menu:
		return
		
	if units_queue.is_empty():
		spawn_menu.ui_queue.text = ""
	else:
		spawn_menu.ui_queue.text = str(units_queue.size() + 1)
	
	if !spawn_timer.is_stopped() and spawn_menu:
		var calculated_value = spawn_timer.wait_time - spawn_timer.time_left
		spawn_menu.progress_bar.value = calculated_value

func add_unit_to_queue(_unit_data :UnitData):
	if !_unit_data:
		return
	
	units_queue.push_back(_unit_data)
	
	if units_queue.size() >= 1 and unit_being_spawned == false:
		start_unit_training()

var current_unit :Unit = null
func start_unit_training():
	if units_queue.is_empty():
		return
	
	var current_unit_data :UnitData = units_queue.front()
	
	if !current_unit_data:
		return
	
	spawn_timer.wait_time = current_unit_data.spawn_time
	
	unit_being_spawned = true
	unit_is_being_trained.emit(unit_being_spawned)
	
	var unit_scene = load(current_unit_data.scene_path) as PackedScene
	current_unit = unit_scene.instantiate()
	
	if controller is PlayerController:
		spawn_menu.progress_bar.max_value = current_unit_data.spawn_time
		spawn_menu.progress_bar.visible = true
	
	units_queue.pop_front()
	spawn_timer.start()

func spawn_unit():
	unit_being_spawned = false
	
	if !current_unit:
		return
	
	if units_queue.is_empty():
		if controller is PlayerController:
			spawn_menu.progress_bar.visible = false
		unit_is_being_trained.emit(false)
	
	if spawn_menu && controller is PlayerController:
		spawn_menu.progress_bar.value = 0
	
	var unit_type :String = current_unit.unit_data.ally_group_name
	var unit_folder = level.get_folder_for_unit_type(unit_type)
	
	current_unit.move_point = controller.move_point
	
	if controller is AIController:
		spawn_point = controller.get_random_spawn_point()
	current_unit.global_transform = spawn_point.global_transform
	
	current_unit.spawned.connect(controller._on_new_unit_spawned)
	
	unit_folder.add_child(current_unit)

	current_unit.spawned.emit(current_unit)

func _on_timer_timeout():
	spawn_unit()
	
	if units_queue.size() >= 1 and unit_being_spawned == false:
		start_unit_training()
