extends Node2D
class_name Arrow

signal reached_target

@onready var hit_box: Hitbox = $HitBox
@onready var delete_timer: Timer = $"Delete Timer"

var archer :Archer
var speed: float = 10  # Speed of the arrow in pixels per second
var arc_height: float = 30  # Height of the arc
var target_position: Vector2
var has_shot: bool = false
var distance_traveled: float = 0
var total_distance: float = 0
var start_position: Vector2
var direction: Vector2
var initial_rotation: float  # This will store the initial rotation angle
var has_missed: bool = false
var target :Node2D = null
var previous_target :Node2D = null

func _ready() -> void:
	hit_box.hit_target.connect(_on_hit_target)
	delete_timer.timeout.connect(_on_delete_timer_timeout)
	reached_target.connect(_on_target_reached)

func _physics_process(delta: float) -> void:
	if has_shot:
		move_arrow()

func _on_hit_target(agent :Node2D):
	var hit_agent :Unit = agent as Unit
	
	if archer.target == agent: 
		queue_free()

func _on_target_reached():
	%"Full Arrow".visible = false
	%"Broken Arrow".visible = true
	$HitBox/CollisionShape2D.disabled = true
	$CPUParticles2D.emitting = true
	delete_timer.start()

func _on_delete_timer_timeout():
	queue_free()

func disable_hitbox():
	hit_box.disable()

func shoot(shooter :RangeUnit, new_target_position: Vector2):
	if archer == null:
		archer = shooter
		
	target_position = new_target_position
	
	hit_box.agent = shooter
	hit_box.damage_component = shooter.damage_component

	start_position = global_position
	direction = (target_position - global_position).normalized()
	total_distance = global_position.distance_to(target_position)
	has_shot = true
	initial_rotation = direction.angle()  # Store the initial rotation
	global_rotation = initial_rotation  # Ensure the arrow points towards the target

func move_arrow():
	var travel = speed
	distance_traveled += travel
	
	var new_position = start_position + direction * distance_traveled

	# Calculate the vertical offset using a sine wave
	var sine_wave_value = -sin((distance_traveled / total_distance) * PI)  # Negative sine for downward arc

	# Flip the vertical offset if direction.x is negative
	var vertical_sign = 1 if direction.x >= 0 else -1
	var vertical_offset = sine_wave_value * arc_height * vertical_sign

	# Apply the vertical offset perpendicular to the direction of travel
	var perpendicular_direction = Vector2(-direction.y, direction.x)
	new_position += perpendicular_direction * vertical_offset

	# Update position
	global_position = new_position

	# Calculate the new direction after moving to adjust rotation
	if new_position != start_position:  # Avoid division by zero and invalid direction vector
		var current_direction = (new_position - start_position).normalized()
		global_rotation = current_direction.angle()  # Ensure the arrow points towards its moving direction
		
	# Ensure consistent rotation by taking the horizontal direction into account
	var rotation_modifier
	if direction.x >= 0:
		rotation_modifier = PI / 8 
	else:
		rotation_modifier = -PI / 8
	
	global_rotation = initial_rotation + -(sine_wave_value * rotation_modifier)

	# Stop the arrow when it reaches the target
	if distance_traveled >= total_distance:
		global_position = target_position
		has_shot = false
		global_rotation = initial_rotation + (rotation_modifier * sine_wave_value)  # Final rotation adjustment
		reached_target.emit()  # Optionally signal that the target was reached
