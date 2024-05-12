extends Node
class_name HealthComponent

signal get_damage

@export var max_hp = 100.0
@export var agent :Node2D
@export var health_bar: PackedScene


@onready var current_hp = max_hp
var hp_bar

func _ready():
	if health_bar:
		hp_bar = health_bar.instantiate()
		hp_bar.max_value = max_hp
		agent.add_child.call_deferred(hp_bar)
		hp_bar.visible = false


func apply_damage(damage_component :DamageComponent):
	var damage = damage_component.get_damage_amount()
	var damage_causer = damage_component.get_damage_causer()
	
	# Observer Pattern.
	get_damage.emit()
	
	current_hp = clampf(current_hp - damage, 0, max_hp)
	
	if current_hp < max_hp and not current_hp <= 0:
		hp_bar.value = current_hp
		hp_bar.visible = true
	
	if current_hp <= 0:
		hp_bar.visible = false
		if !agent.has_method("die"):
			return

		agent.call_deferred("die")
		
		if damage_causer is MeleeUnit:
			damage_causer.is_free = true
			damage_causer.state_changed.emit(damage_causer, damage_causer.is_free)
		
		return
	
func heal(heal_amount :float):
	current_hp = clampf(current_hp + heal_amount, current_hp, heal_amount)
