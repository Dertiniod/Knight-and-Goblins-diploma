extends Zone
class_name GoldMine

signal object_destroyed(object :LevelObject)

@onready var attack_points: Node2D = $AttackPoints
@onready var animation_player: AnimationPlayer = $AnimNodes/AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var main_sprites = $MainSprites

var stage :int = 0
var taken_points_array: Array[AttackPoint] = []
var free_attack_points: Array[AttackPoint] = []

func _ready() -> void:
	super()
	
	workers = 10
	start_working()
	
	add_to_group("knights")
	
	for marker in attack_points.get_children():
		var point: AttackPoint = marker
		free_attack_points.append(point)
		
	health_component.get_damage.connect(_on_get_damage)

func get_available_attack_point() -> AttackPoint:
	if free_attack_points.size() > 0:
		var point_index = get_random_attack_point_index(free_attack_points)
		var taken_point: AttackPoint = free_attack_points.pop_at(point_index)
		taken_points_array.push_back(taken_point)
		return taken_point
	else:
		# Handle the case when there are no free attack points available.
		return null

func make_point_available(point: AttackPoint):
	var freed_point_index: int = taken_points_array.find(point)
	if freed_point_index != -1: # Correctly checks if the point was found
		free_attack_points.append(taken_points_array.pop_at(freed_point_index))

func get_random_attack_point_index(array: Array) -> int:
	return randi() % array.size()

func is_there_free_points() -> bool:
	return free_attack_points.size() > 0

func die():
	stop_working()
	object_destroyed.emit(self)
	animation_player.play("destroy")
	$CollisionShape2D.disabled = true
	$AnimNodes/PointLight2D.visible = false

func _on_get_damage():
	var tween = get_tree().create_tween()
	# Tween the scale property with a relative increas
	tween.tween_property(main_sprites, "scale", Vector2(1.1, 1), 0.075) # Set duration to 0.3 seconds
	# After reaching the scaled state, tween back to scale 1.0
	tween.chain().tween_property(main_sprites, "scale", Vector2(1, 1), 0.075)
	
	play_damage_effects()
	
func play_damage_effects():
	var current_hp = health_component.current_hp
	var max_hp = health_component.max_hp
	
	if max_hp * 0.2 >= current_hp:
		animation_player.play("high_damage")
	elif max_hp * 0.5 >= current_hp:
		animation_player.play("mid_damage")
	elif max_hp * 0.8 >= current_hp:
		animation_player.play("low_damage")

func earn_resource():
	super()
	var add_income :int = income / available_workers_slots
	GameResourcesManager.earn_gold(add_income)
