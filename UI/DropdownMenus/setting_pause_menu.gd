extends DropdownMenu
class_name SettingsPauseMenu

signal return_to_pause

func _ready() -> void:
	super()
	
	%ReturnToMenuButton.pressed.connect(func(): return_to_pause.emit())
