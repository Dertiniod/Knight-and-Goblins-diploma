@tool
extends BTAction

@export var bb_target_position_var := "target_position"
@export var tolerance := 75.0

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Arrive"


# Called to initialize the task.
func _setup() -> void:
	pass


# Called when the task is entered.
func _enter() -> void:
	pass


# Called when the task is exited.
func _exit() -> void:
	pass


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	var target_position = blackboard.get_var(bb_target_position_var, Vector2.ZERO)
	
	if target_position.distance_to(agent.global_position) < tolerance:
		return SUCCESS
	
	var direction = agent.global_position.direction_to(target_position)
	agent.direction = direction
	agent.velocity = direction * agent.speed * delta * 4
	agent.move_and_slide()
	agent.update_facing()
	
	return RUNNING
