@tool
extends BTAction

@export var bb_target: String = "target"
@export var bb_target_position: String = "target_position"
@export var bb_available_enemies: String = "available_enemies"
@export var bb_is_free: String = "is_free"
@export var bb_is_dead: String = "is_dead"

var target :Node2D
var target_position :Vector2
var available_enemies :Array
var is_free :bool
var is_dead :bool

func _generate_name() -> String:
	return "Update Blackboard Variables"

func _tick(delta: float) -> Status:
	target = agent.target
	target_position = agent.target_position
	available_enemies = agent.available_enemies
	is_free = agent.is_free
	is_dead = agent.is_dead
	
	blackboard.set_var(bb_target, target)
	blackboard.set_var(bb_target_position, target_position)
	blackboard.set_var(bb_available_enemies, available_enemies)
	blackboard.set_var(bb_is_free, is_free)
	blackboard.set_var(bb_is_dead, is_dead)
	
	return SUCCESS
