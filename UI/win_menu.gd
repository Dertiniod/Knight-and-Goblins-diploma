extends DropdownMenu
class_name GameFinishMenu

signal restart_level_clicked
signal back_to_menu_clicked

func _ready():
	%RestartButton.pressed.connect(func(): restart_level_clicked.emit()) 
	%ExitButton.pressed.connect(func(): back_to_menu_clicked.emit())
