extends LevelObject
class_name ActiveObject

signal active_object_clicked(object :ActiveObject)

func _ready() -> void:
	if GlobalData.player_controller:
		GlobalData.get_player_controller().add_active_object_to_controller(self)
