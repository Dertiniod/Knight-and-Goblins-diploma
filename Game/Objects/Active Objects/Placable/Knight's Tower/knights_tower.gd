extends Placable
class_name KnightsTower

@export var archer_scene :PackedScene

func _ready() -> void:
	var archer = archer_scene.instantiate()
	
	archer.global_position = $Marker2D.global_position
	add_child(archer)
	
	await get_tree().create_timer(0.05).timeout
	
	# Crutch to add archer's parent after some time, so it's position calculated properly.
	# TODO: Find a better way to put archer into a Units->Knights node in level.
	archer.reparent(get_tree().get_first_node_in_group("units_folder").get_node("Knights"))
