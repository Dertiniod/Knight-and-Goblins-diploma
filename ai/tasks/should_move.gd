@tool
extends BTCondition

@export var target_var := "target"

@export var distance_min: float
@export var distance_max: float

var target: Node2D = null

func _generate_name() -> String:
	return "Should Move?"

func _enter():
	if is_instance_valid(agent.target):
		target = agent.target
	if not is_instance_valid(target):
		return FAILURE

func _tick(_delta: float) -> Status:
	if not is_instance_valid(target):
		return FAILURE

	var target_position :Vector2 = blackboard.get_var("target_position", Vector2.ZERO)
	var target = blackboard.get_var(target_var)
	var distance: float = agent.global_position.distance_to(target_position)
	
	if distance >= distance_min and distance <= distance_max:
		return SUCCESS
	else:
		return FAILURE
