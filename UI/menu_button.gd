extends TextureButton
class_name HUDMenuButton

signal hud_button_pressed(menu_type :GameEnums.DROPDOWN_MENU_TYPE)

@export var type :GameEnums.DROPDOWN_MENU_TYPE

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed():
	hud_button_pressed.emit(type)
