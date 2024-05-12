extends RangeUnit
class_name Archer

@export var arrow_scene :PackedScene

@onready var shoot_cooldown: Timer = $"Shoot Cooldown"
@onready var arrow_spawn_point: Marker2D = $ArrowSpawnPoint
@onready var miss_text = $MissNodes/CPUParticles2D


var attack_speed :float = 0.0:
	set(value):
		attack_speed = value
		shoot_cooldown.wait_time = attack_speed
var direction :Vector2
var can_shoot :bool = true
var miss_chance: float = 0.3
var predictive_offset :float = 20.0

func _ready() -> void:
	super()
	
	animation_player.play("idle")
	
	shoot_cooldown.timeout.connect(_on_shoot_cooldown_timeout)
	animation_player.animation_finished.connect(_on_animation_finished)

func _data_init(data :UnitData):
	super(data)
	
	attack_speed = data.attack_speed
	miss_chance = data.miss_chance
	damage_component.damage_amount = data.damage
	health_component.max_hp = data.health

func _process(delta: float) -> void:
	if is_instance_valid(target):
		target_position = target.global_position
		if can_shoot:
			update_archer_animation(target_position)

func _on_animation_finished(name :String):
	animation_player.play("idle")

func _on_shoot_cooldown_timeout():
	can_shoot = true

func change_collision_disabled(should_disable :bool):
	$SpotArea/CollisionShape2D.disabled = should_disable

func find_target():
	if available_enemies.is_empty():
		is_free = true
		return null

	var nearest_unit_target: Unit = null
	var nearest_unit_distance: float = INF

	for enemy in available_enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_squared_to(enemy.global_position)
			if enemy is MeleeUnit and distance < nearest_unit_distance:
				nearest_unit_distance = distance
				nearest_unit_target = enemy
	if nearest_unit_target:
		is_free = false
		return nearest_unit_target
	else:
		is_free = true
		return null

func update_archer_animation(target_position):
	if !can_shoot:
		return
		
	shoot_cooldown.start()
	can_shoot = false
	
	direction = global_position.direction_to(target_position)
	var angle = direction.angle()

	face_dir(direction.x)

	# Determine animation based on the angle
	if angle > -PI/8 and angle < PI/8:
		# Right (shot side)
		animation_player.play("attack_side")
	elif angle >= PI/8 and angle <= 3*PI/8:
		# Down-right (shot down side)
		animation_player.play("attack_down_side")
	elif angle > 3*PI/8 and angle < 5*PI/8:
		# Down (shot down)
		animation_player.play("attack_down")
	elif angle >= 5*PI/8 and angle <= 7*PI/8:
		# Down-left (shot down side)
		animation_player.play("attack_down_side")
	elif (angle > 7*PI/8 and angle <= PI) or (angle < -7*PI/8 and angle >= -PI):
		# Left (shot side)
		animation_player.play("attack_side")
	elif angle < -5*PI/8 and angle > -7*PI/8:
		# Up-left (shot up side)
		animation_player.play("attack_up_side")
	elif angle <= -3*PI/8 and angle >= -5*PI/8:
		# Up (shot up)
		animation_player.play("attack_up")
	elif angle < -PI/8 and angle > -3*PI/8:
		# Up-right (shot up side)
		animation_player.play("attack_up_side")
	else:
		# Default to some animation if needed
		animation_player.play("idle")

func spawn_arrow():
	if !target:
		return
		
	var angle = direction.angle()
	
	var spawn_location : Vector2 = arrow_spawn_point.global_position
	var arrow : Arrow = arrow_scene.instantiate()

	get_parent().add_child(arrow)
	
	arrow.global_position = spawn_location
	
	var shooting_target_position :Vector2 = target.global_position + target.get_unit_movement_direction() * predictive_offset
	
	# Apply a random miss with about 30% probability
	if randf_range(0, 1) < miss_chance:
		if target:
			arrow.disable_hitbox()
			miss_text.emitting = true
			shooting_target_position = get_miss_offset(target.global_position)
			
	arrow.shoot(self, shooting_target_position)

func get_miss_offset(_target :Vector2):
	var side :int = 0
	if randi_range(-1, 1) >= 0:
		side = 1
	else:
		side = -1

	var miss_offset_x = side * randf_range(150, 250)
	var miss_offset_y = randf_range(-50, 50) 
	var miss_offset = Vector2(miss_offset_x, miss_offset_y)

	var new_target_position = _target + miss_offset
	return new_target_position

func delete_enemy_from_available_enemies(body: Node2D):
	super(body)
	reconsider_target()
