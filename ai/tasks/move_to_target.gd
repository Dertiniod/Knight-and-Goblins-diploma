extends BTAction

@export var target_var := "target"
@export var bb_is_dead := "is_dead"
@export var arrival_radius := 70.0

var separation_weight := 5.0
var arrive_weight := 15.0
var max_speed := 300.0
var max_force := 70.0
var desired_separation := 100
var all_units: Array = []
var target: Node2D 
var navigation_agent: NavigationAgent2D

func _setup():
	navigation_agent = agent.get_node("NavigationAgent2D")

func _generate_name() -> String:
	return "Move to Target"

func _enter():
	all_units = agent.get_tree().get_nodes_in_group(agent.ally_group_name)
	all_units += agent.get_tree().get_nodes_in_group(agent.enemy_group_name)
	navigation_agent.target_desired_distance = arrival_radius

func _tick(delta: float) -> Status:
	if !agent.has_initialized:
		return RUNNING
	
	var target: Node2D = null
	if is_instance_valid(agent.target):
		target = agent.target
	if not is_instance_valid(target):
		return FAILURE

	var agent_position: Vector2 = agent.global_position
	var target_position: Vector2 = navigation_agent.target_location
	var distance_to_target_position: float = agent_position.distance_to(target_position)

	var is_dead = blackboard.get_var(bb_is_dead, false)
	if is_dead:
		return FAILURE
		
	if target is AttackPoint and distance_to_target_position < arrival_radius:
		if distance_to_target_position <= 5.0:
			var direction = agent_position.direction_to(target_position)
			var cardinal_direction = round_direction_vector_to_cardinal(direction)
			agent.global_position = target.global_position
			agent.velocity = Vector2.ZERO
			agent.face_dir(cardinal_direction.x)
			return SUCCESS
		else:
			agent.global_position = flerp_to_position(agent_position, target_position, delta)
			return RUNNING
		
	if is_target_a_unit(target) and distance_to_target_position < arrival_radius:
		var direction = agent_position.direction_to(target_position)
		var cardinal_direction = round_direction_vector_to_cardinal(direction)
		agent.global_position = align_agent(agent_position, target_position, cardinal_direction, delta)
		if is_aligned(agent_position, target_position, cardinal_direction):
			agent.face_dir(cardinal_direction.x)
			return SUCCESS
		else:
			return RUNNING
		
	var dynamic_separation_weight = separation_weight * max(0.1, 1 - distance_to_target_position / arrival_radius)
	var separation_force = calculate_separation() * dynamic_separation_weight
	var arrive_force = arrive(target_position) * arrive_weight
	var steering_force = separation_force + arrive_force

	var acceleration = limit_vector(steering_force, max_force)
	agent.velocity += acceleration * delta
	agent.velocity = limit_vector(agent.velocity, max_speed)

	if distance_to_target_position > arrival_radius:
		var next_point = navigation_agent.get_next_path_position()
		if next_point != Vector2.INF:
			var direction_to_next_point = agent_position.direction_to(next_point).normalized()
			arrive_force = direction_to_next_point * max_speed
		else:
			arrive_force = arrive(target_position) * arrive_weight
		acceleration = (separation_force + arrive_force).normalized() * max_force
		agent.velocity = limit_vector(acceleration, max_speed)
	
	if distance_to_target_position < arrival_radius:
		agent.velocity = Vector2.ZERO
		return SUCCESS

	agent.move_and_slide()
	agent.update_facing()
	return RUNNING

func flerp_to_position(current_position: Vector2, target_position: Vector2, delta: float) -> Vector2:
	var distance = current_position.distance_to(target_position)
	var speed = max_speed / 5 # This is the constant speed at which the unit should move.
	
	# Calculate the fraction of the distance to move this frame, ensuring it doesn't exceed 1.
	var move_fraction = delta * speed / distance
	move_fraction = min(move_fraction, 1)
	
	# Use linear_interpolate with the calculated fraction to move towards the target at a constant speed.
	return lerp(current_position, target_position, move_fraction)


func limit_vector(vector: Vector2, max_value: float) -> Vector2:
	if vector.length() > max_value:
		return vector.normalized() * max_value
	return vector

func calculate_separation() -> Vector2:
	var steer = Vector2.ZERO
	var total = 0
	for unit in all_units:
		if unit != agent and unit != null:
			var distance = agent.global_position.distance_to(unit.global_position)
			if distance < desired_separation:
				var diff = (agent.global_position - unit.global_position).normalized() / distance
				steer += diff
				total += 1
	if total > 0:
		steer = (steer / total).normalized() * max_speed
		steer -= agent.velocity
		steer = limit_vector(steer, max_force)
	return steer

func arrive(target_position: Vector2) -> Vector2:
	var desired_velocity = target_position - agent.global_position
	var distance = desired_velocity.length()
	var speed = max_speed
	if distance < arrival_radius:
		speed = max_speed * (distance / arrival_radius)
	desired_velocity = desired_velocity.normalized() * speed - agent.velocity
	return limit_vector(desired_velocity, max_force)


func is_target_a_unit(target: Node2D) -> bool:
	return target is Unit

func round_direction_vector_to_cardinal(dir: Vector2) -> Vector2:
	var x = 0
	var y = 0
	if abs(dir.x) < abs(dir.y):
		x = 0
	else:
		x = int(sign(dir.x))
	if abs(dir.y) < abs(dir.x):
		y = 0
	else:
		y = int(sign(dir.y))
	return Vector2(x, y)

func align_agent(player_position, target_position, desired_direction, delta):
	var new_player_position = player_position
	var interpolation_speed = 5.0  # Adjust this value to control the alignment speed
	if desired_direction.x != 0:
		new_player_position.y = lerp(player_position.y, target_position.y, delta * interpolation_speed)
	elif desired_direction.y != 0:
		new_player_position.x = lerp(player_position.x, target_position.x, delta * interpolation_speed)
	return new_player_position

func is_aligned(current_position, target_position, desired_direction) -> bool:
	if desired_direction.x != 0:
		return abs(current_position.y - target_position.y) <= 5
	elif desired_direction.y != 0:
		return abs(current_position.x - target_position.x) <= 5
	return false
