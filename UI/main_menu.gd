extends CanvasLayer
class_name MainMenu

signal level_chosen(menu, level_data)

func _ready() -> void:
	%ExitButton.pressed.connect(func() :quit_game())

func quit_game():
	# TODO: additional confirmation window here.
	
	# quit after player confirmed quiting
	get_tree().quit()
