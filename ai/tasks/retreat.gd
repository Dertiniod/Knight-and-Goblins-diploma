@tool
extends BTAction

@export var target_var := "target"
@export var tolerance := 20.0

@export var bb_retreat_position := "retreat_position"
@export var bb_is_retreat_finished := "is_retreat_finished"

var retreat_position :Vector2

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Retreat"

func _enter() -> void:
	retreat_position = blackboard.get_var(bb_retreat_position, Vector2.ZERO)

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var agent_position :Vector2 = agent.global_position
	var direction = agent.global_position.direction_to(retreat_position)
	
	agent.direction = direction
	agent.velocity = direction * agent.speed * delta * 4
	
	if agent_position.distance_to(retreat_position) < tolerance:
		blackboard.set_var(bb_is_retreat_finished, true)
		return FAILURE
	
	agent.update_facing()
	agent.move_and_slide()
	
	return RUNNING
