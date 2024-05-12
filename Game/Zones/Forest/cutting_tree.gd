extends Node2D
class_name Axe

signal make_cut

func choose_position():
	make_cut.emit()
	
func start_cutting_animation():
	visible = true
	$AnimationPlayer.active = true
	$AnimationPlayer.play("Hammer")
