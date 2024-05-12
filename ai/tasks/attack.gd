@tool
extends BTAction

var should_attack :bool = true

func _setup() -> void:
	agent.attack_finished.connect(_on_attack_finished)
	
func _enter():
	should_attack = true
	agent.start_attack()
	
func _on_attack_finished():
	should_attack = false
	
func _tick(delta: float) -> Status:
	if should_attack:
		return RUNNING
	else:
		return SUCCESS
