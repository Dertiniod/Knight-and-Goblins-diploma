extends Node2D
class_name Controller

signal no_controlled_units_remain()

@onready var spawn_component: SpawnComponent = $SpawnComponent
@onready var move_point: MovePoint = $MovePoint

@export var main_building :ActiveObject
@export var available_units_data :Dictionary

var controlled_units :Array[Unit]
var level :Level:
	set(value):
		level = value
		spawn_component.level = level
var spawn_point :Node2D:
	set(value):
		spawn_point = value
		spawn_component.spawn_point = spawn_point


func initialize_controller():
	if get_parent() is Level:
		level = get_parent()
	else:
		print("Level ain't available")
		get_tree().quit()
	spawn_point = main_building.unit_spawn_point

func _on_new_unit_spawned(new_unit :Unit):
	new_unit.died.connect(_on_controlled_unit_died)
	controlled_units.push_back(new_unit)

func start_unit_spawning(unit_data :UnitData):
	if spawn_component && unit_data:
		spawn_component.add_unit_to_queue(unit_data)

func _on_controlled_unit_died(dead_unit :Unit):
	if controlled_units.has(dead_unit):
		controlled_units.erase(dead_unit)
	if controlled_units.is_empty():
		no_controlled_units_remain.emit()
