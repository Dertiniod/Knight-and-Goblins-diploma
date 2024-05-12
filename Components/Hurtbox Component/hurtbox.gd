extends Area2D
class_name Hurtbox

@export var agent :Node2D
@export var health_component :HealthComponent

var enemy_group_name :String

func _ready() -> void:
	connect("area_entered", on_hurtbox_entered)
	connect("area_exited", on_hurtbox_exited)

func on_hurtbox_entered(area :Area2D):
	if area is Hitbox:
		area.hit_target.emit(agent)
		
		var enemy_group_name :String = agent.enemy_group_name
		var enemy_hitbox :Hitbox = area
		var enemy = enemy_hitbox.agent
		
		if enemy.target != agent and not enemy.target is AttackPoint:
			return
		
		if !enemy.is_in_group(enemy_group_name):
			return
		
		var enemy_damage_copmonent :DamageComponent = enemy_hitbox.damage_component
		health_component.apply_damage(enemy_damage_copmonent)


func on_hurtbox_exited(area :Area2D):
	pass
