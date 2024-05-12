extends DropdownMenu
class_name PauseMenu

signal resume_game_clicked
signal settings_clicked
signal exit_clicked

func _ready() -> void:
	super()
	
	%ResumeButton.pressed.connect(func(): resume_game_clicked.emit())
	%SettingsButton.pressed.connect(func(): settings_clicked.emit())
	%ExitButton.pressed.connect(func(): exit_clicked.emit())
