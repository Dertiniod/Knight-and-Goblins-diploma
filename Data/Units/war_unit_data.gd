extends UnitData
class_name WarUnitData

@export var damage :int
@export var attack_speed :float

@export var can_miss :bool = false
@export_range(0.0, 1.0) var miss_chance :float = 0.0

var strength :float

func calculate_strength():
	var new_strength = damage / attack_speed / spawn_time + (health * 0.03)
	if can_miss:
		new_strength += (1.0 - miss_chance) * 10
	strength = new_strength
	return strength

func apply_buff(wave_number :int, level_number: int):
	damage *= 1.0 + (level_number * 0.05)
	attack_speed *= 1.0 - (level_number * 0.03)
	spawn_time *= 1.0 - (wave_number * 0.02)
