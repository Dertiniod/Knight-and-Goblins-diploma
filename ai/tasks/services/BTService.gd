extends BTAction
class_name BTService

@export var interval :float = 1.0
var timer = 0.0

func _tick(delta):
	timer += delta
	if timer >= interval:
		timer = 0.0
		perform_service()

func perform_service():
	pass
