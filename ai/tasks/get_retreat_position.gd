@tool
extends BTAction


func _generate_name() -> String:
	return "GetRetreatPosition"


func _tick(delta: float) -> Status:
	var target_position = blackboard.get_var("target_position", Vector2.ZERO) 
	
	var retreat_direction :Vector2 = agent.global_position.direction_to(target_position) * -1
	blackboard.set_var("target_position", agent.to_global(retreat_direction * 400)) 
	
	return SUCCESS
