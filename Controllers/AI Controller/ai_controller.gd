extends Controller
class_name AIController

@export var spawn_buildings :Node2D

var units_to_spawn :Array[UnitData]

func create_wave(wave_info: WaveData):
	if !spawn_component:
		return
		
	var unit_data :UnitData = get_unit_to_spawn() as WarUnitData
	
	wave_info.total_wave_strength += unit_data.calculate_strength()
	
	for i in wave_info.total_units:
		# Make sure first unit always spawns with the minial delay.
		if i == 0:
			var new_unit_data :UnitData = unit_data.duplicate()
			new_unit_data.spawn_time = 0.0
			spawn_component.add_unit_to_queue(new_unit_data)
		else:
			spawn_component.add_unit_to_queue(unit_data)

func get_unit_to_spawn():
	return GlobalData.goblins_data.pick_random() 

func get_random_spawn_point() -> Node2D:
	var spawn_buildings_amount :int = spawn_buildings.get_child_count()
	var rand_buidling_index = randi_range(0, spawn_buildings_amount - 1)
	
	var spawn_buidling :SpawnerObject = spawn_buildings.get_child(rand_buidling_index) as SpawnerObject
	return spawn_buidling.unit_spawn_point
