extends Unit
class_name MeleeUnit

signal attack_finished
signal state_changed(body :Node2D, is_free :bool)

var is_dead = false:
	set(new_value):
		is_dead = new_value
		blackboard.set_var("is_dead", is_dead)
var attack_speed: float:
	set(value):
		attack_speed = value
		blackboard.set_var("attack_speed", attack_speed)

# Main functions:
func _ready() -> void:
	bt_player = $BTPlayer
	
	super()
	
	if move_point:
		target = move_point
	
	animation_player.animation_finished.connect(_on_animation_finished)
	health_component.get_damage.connect(_on_get_damage)
	
	update_path_to_target()

func _physics_process(delta: float) -> void:
	super(delta)
	update_path_to_target()

func _data_init(data :UnitData):
	super(data)
	damage_component.damage_amount = data.damage
	attack_speed = data.attack_speed
	health_component.max_hp = 100

func set_new_move_point_position():
	already_got_rand_point = false
	target_position = move_point.global_position

func find_closest_enemy_to(position: Vector2) -> Unit:
	var closest_enemy: Unit = null
	var closest_distance = INF
	for enemy in available_enemies:
		if enemy.is_in_group(enemy_group_name) and enemy is Unit:
			var distance = position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy
	return closest_enemy

# Functions related to Attack:
func check_if_target_is_in_attack_range(target :Node2D) -> bool:
	var overlapping :Array
	if target is Area2D:
		overlapping = attack_area.get_overlapping_areas()
	else:
		overlapping = attack_area.get_overlapping_bodies()
	return overlapping.has(target)

var has_just_started_attack :bool = false

func start_attack():
	var attacking_direction :Vector2
	
	if target.owner is LevelObject:
		attacking_direction = global_position.direction_to(target.owner.global_position)
	else:
		attacking_direction = global_position.direction_to(target.global_position)
	
	attacking_direction = round_direction_vector_to_cardinal(attacking_direction)
	face_dir(attacking_direction.x)
	
	if has_just_started_attack:
		return
	
	has_just_started_attack = true
	
	if attacking_direction == Vector2(1, 0) || attacking_direction == Vector2(-1, 0):
		animation_player.play("attack_side")
	elif attacking_direction == Vector2(0, 1):
		animation_player.play("attack_down") 
	elif attacking_direction == Vector2(0, -1):
		animation_player.play("attack_up")

func _on_animation_finished(anim_name: String):
	if anim_name.begins_with("attack"):
		has_just_started_attack = false
		attack_finished.emit()

# Other gameplay related functions:
func die():
	died.emit(self)
	$CollisionShape2D.disabled = true
	is_free = false
	state_changed.emit(self, is_free)
	is_dead = true

# Effects:
func play_damage_effects():
	character_sprite.material.set_shader_parameter("hit_opacity", 1)
	await get_tree().create_timer(0.1).timeout
	character_sprite.material.set_shader_parameter("hit_opacity", 0)

# Helpers:
func update_path_to_target() -> void:
	if target == null:
		return
	target_position = target.global_position

func round_direction_vector_to_cardinal(dir: Vector2) -> Vector2:
	var x = 0 if abs(dir.x) < abs(dir.y) else int(sign(dir.x))
	var y = 0 if abs(dir.y) < abs(dir.x) else int(sign(dir.y))
	return Vector2(x, y)

func check_if_dead():
	return blackboard.get_var("is_dead")

# Signals:
func _on_get_damage():
	play_damage_effects()

func _on_ally_died(dead_unit):
	if is_instance_valid(target) and target is AttackPoint:
		var closest_enemy = find_closest_enemy_to(global_position)
		if closest_enemy:
			reconsider_target()
