extends Node
class_name DamageComponent

@export var damage_causer :Unit
@export var damage_amount :float

func get_damage_amount():
	return damage_amount

func get_damage_causer():
	return damage_causer
