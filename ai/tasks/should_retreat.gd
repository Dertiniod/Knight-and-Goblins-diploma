@tool
extends BTCondition

@export var bb_is_hp_low :String = "is_hp_low"
@export var bb_is_retread_finished :String = "is_retreat_finished" 


func _generate_name() -> String:
	return "Should retreat?"

func _tick(_delta: float) -> Status:
	var is_hp_low = blackboard.get_var(bb_is_hp_low)
	var is_retread_finished = blackboard.get_var(bb_is_retread_finished)
	
	if is_hp_low && !is_retread_finished:
		print(agent.is_dead)
		return SUCCESS
	else:
		return FAILURE
