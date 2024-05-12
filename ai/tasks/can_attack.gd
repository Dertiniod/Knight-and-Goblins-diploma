@tool
extends BTCondition

@export var target_var := "target"

func _generate_name() -> String:
	return "Can attack?"

func _tick(_delta: float) -> Status:
	var target: Node2D = null
	if is_instance_valid(agent.target):
		target = agent.target
	if not is_instance_valid(target):
		return FAILURE
	
	if target.owner is LevelObject:
		target = target.owner
	
	if target != MovePoint:
		if agent.check_if_target_is_in_attack_range(target):
			return SUCCESS
	return FAILURE
