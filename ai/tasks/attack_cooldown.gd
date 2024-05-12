extends BTCooldown
@export var attack_speed :float

var already_initialized :bool = false

func _enter():
	if !already_initialized:
		attack_speed = blackboard.get_var("attack_speed", 1.5)
		duration = attack_speed
		already_initialized = true
