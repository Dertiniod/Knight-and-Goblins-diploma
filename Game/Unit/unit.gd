extends CharacterBody2D
class_name Unit

signal died(died_unit :Unit)
signal spawned(spawned_unit :Unit)
signal target_changed(target: Node2D)

@export_enum("RIGHT:1", "LEFT:-1") var starting_direction :int
@export var move_point :Node2D
@export var unit_data :UnitData

var ally_group_name :String
var enemy_group_name :String

@onready var blackboard :Blackboard
@onready var attack_area: Area2D = $AttackArea
@onready var spot_area: Area2D = $SpotArea
@onready var health_component: HealthComponent = $HealthComponent
@onready var damage_component: DamageComponent = $DamageComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var character_sprite: Sprite2D = $CharacterSprite
@onready var hitbox :Area2D = $HitBox


var bt_player: BTPlayer

var already_got_rand_point :bool = false
var available_enemies: Array:
	set(new_array):
		available_enemies = new_array
		blackboard.get_var("available_enemies", available_enemies)
var is_free: bool = true:
	set(new_value):
		is_free = new_value
		
		if blackboard != null:
			blackboard.set_var("is_free", is_free)
var target: Node2D = null:
	set(new_value):
		var last_target = target
		target = new_value
		
		if !is_instance_valid(target):
			reconsider_target()  # Ensures that a new target is found if the current one is invalid
			return
			
		emit_signal("target_changed", target)
			
		if !is_instance_valid(last_target):
			return
				
		if last_target is AttackPoint and last_target.owner is LevelObject:
			last_target.owner.make_point_available(last_target)
				
		target = new_value
			
		if !target:
			return
			
		if blackboard:
			blackboard.set_var("target", target)
			
		target_position = target.global_position
			
		if target != move_point:
			is_free = false
			already_got_rand_point = false
		else:
			already_got_rand_point = true
var attack_point :AttackPoint = null
var target_position :Vector2:
	set(new_position):
		if !is_instance_valid(target):
			target = move_point
		
		if target is MovePoint:
			if !already_got_rand_point:
				target_position = get_random_point_in_radius(new_position, 25)
		else:
			target_position = new_position
		navigation_agent.target_position = target_position
		
		if blackboard != null:
			blackboard.set_var("target_position", new_position)

func _data_init(data :UnitData):
	ally_group_name = unit_data.ally_group_name
	enemy_group_name = unit_data.enemy_group_name

func _ready() -> void:
	if bt_player != null:
		blackboard = bt_player.blackboard
	
	spot_area.connect("body_entered", _on_body_entered)
	spot_area.connect("body_exited", _on_body_exited)
	spot_area.connect("area_entered", _on_area_entered)
	spot_area.connect("area_exited", _on_area_exited)
	
	if unit_data:
		_data_init(unit_data)
		add_to_group(ally_group_name)
	
	for enemy in get_tree().get_nodes_in_group(enemy_group_name):
		if enemy is Unit and enemy != self: 
			connect("spawned", enemy._on_new_unit_spawned)

	for ally in get_tree().get_nodes_in_group(ally_group_name):
		if ally is Unit and ally != self:
			connect("spawned", ally._on_new_unit_spawned)
	
	face_dir(starting_direction)

func _on_new_unit_spawned(new_unit :Unit):
	if new_unit == self:
		return
	
	if new_unit.is_in_group(ally_group_name):
		new_unit.died.connect(_on_ally_died)
		died.connect(new_unit._on_ally_died)
	else:
		new_unit.died.connect(_on_enemy_died)
		died.connect(new_unit._on_enemy_died)

var _frames_since_facing_update = 0
func update_facing() -> void:
	if _frames_since_facing_update >= 60:
		face_dir(velocity.x)
		_frames_since_facing_update = 0
	_frames_since_facing_update += 1

func face_dir(dir: float) -> void:
	if dir > 0:
		transform.x.x = 1
	if dir < 0:
		transform.x.x = -1

# Finding target related functions:
var has_initialized: bool = false
var find_target_timer: float = 0.1
var sec_passed: float = 0.0
func _physics_process(delta: float) -> void:
	sec_passed += delta
	if sec_passed >= find_target_timer:
		sec_passed = 0.0
		
		if is_free or target == null:
			reconsider_target()
			
		# var new_target = find_target()
		# target = new_target
		has_initialized = true
	
		if is_instance_valid(target) and target is AttackPoint:
			reconsider_target()

func find_target():
	if available_enemies.is_empty():
		is_free = true
		return move_point

	var nearest_unit_target: Unit = null
	var nearest_building_target: LevelObject = null
	var nearest_unit_distance: float = INF
	var nearest_building_distance: float = INF

	# Separate the search for units and buildings
	for enemy in available_enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_squared_to(enemy.global_position)
			
			if enemy is Unit and enemy.is_free and distance < nearest_unit_distance:
				nearest_unit_distance = distance
				nearest_unit_target = enemy
			elif enemy is LevelObject and distance < nearest_building_distance and enemy.is_there_free_points():
				nearest_building_distance = distance
				nearest_building_target = enemy

	# Prioritize unit targets over buildings
	if nearest_unit_target:
		is_free = false
		nearest_unit_target.is_free = false
		nearest_unit_target.target = self
		return nearest_unit_target
	elif nearest_building_target:
		is_free = false
		if attack_point == null:
			attack_point = nearest_building_target.get_available_attack_point()
			nearest_building_target.object_destroyed.connect(_on_unit_destroyed_object)
		return attack_point
	else:
		is_free = true
		return move_point

func reconsider_target():
	var new_target = find_target()
	
	if new_target != target:
		if is_instance_valid(target) and target is AttackPoint:
			target.owner.make_point_available(target)
		target = new_target
		target_changed.emit(target)
	
func get_ally_group_name():
	return ally_group_name

# Managing available_enemies Array:
func add_enemy_to_available_enemies(body: Node2D):
	if body.is_in_group(enemy_group_name) and not available_enemies.has(body):
		available_enemies.append(body)
		
		if is_instance_valid(target) and target is AttackPoint or is_free:
			reconsider_target()

func delete_enemy_from_available_enemies(body: Node2D):
	if available_enemies.has(body):
		available_enemies.erase(body)

# SIGNALS
func _on_body_entered(body :CharacterBody2D):
	add_enemy_to_available_enemies(body as Unit)
	
func _on_body_exited(body :CharacterBody2D):
	delete_enemy_from_available_enemies(body as Unit)
	
func _on_area_entered(area :Area2D):
	add_enemy_to_available_enemies(area)
	
func _on_area_exited(area :Area2D):
	delete_enemy_from_available_enemies(area)
	
func _on_enemy_died(dead_unit):
	if is_instance_valid(target) && target == dead_unit:
		delete_enemy_from_available_enemies(dead_unit)
		reconsider_target()

func _on_ally_died(dead_unit):
	pass

func die():
	pass
	
func _on_unit_destroyed_object(object :LevelObject):
	object.disconnect("object_destroyed", _on_unit_destroyed_object)
	attack_point = null

func get_random_point_in_radius(center: Vector2, radius: float) -> Vector2:
	var angle := randf_range(0, 2 * PI) # Random angle in radians
	var rand_radius := randf() * radius # Random radius within the maximum radius

	# Convert polar coordinates (angle, rand_radius) to Cartesian (x, y) and adjust by existing point
	var x := center.x + rand_radius * cos(angle)
	var y := center.y + rand_radius * sin(angle)

	return Vector2(x, y)

func get_unit_movement_direction():
	return global_position.direction_to(navigation_agent.get_next_path_position()).normalized()
