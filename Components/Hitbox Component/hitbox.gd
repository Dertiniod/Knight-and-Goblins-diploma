extends Area2D
class_name Hitbox

signal hit_target(agent :Node2D)

@export var agent :Unit
@export var damage_component :DamageComponent
@export var collision_shape :CollisionShape2D

func _ready() -> void:
	connect("area_entered", on_hitbox_entered)
	connect("area_exited", on_hitbox_exited)

func disable():
	if is_instance_valid(collision_shape):
		collision_shape.disabled = true

func on_hitbox_entered(area :Hurtbox):
	pass

func on_hitbox_exited(area :Area2D):
	pass
