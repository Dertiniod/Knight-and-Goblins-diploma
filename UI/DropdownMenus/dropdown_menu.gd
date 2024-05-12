extends CanvasLayer
class_name DropdownMenu

@export var type :GameEnums.DROPDOWN_MENU_TYPE
@export var anim_player :AnimationPlayer

signal closed

var initial_position :Vector2

func _ready() -> void:
	if anim_player:
		anim_player.animation_finished.connect(_on_animation_finished)
	process_mode = Node.PROCESS_MODE_ALWAYS
	initial_position = %Control.position

func _on_animation_finished(name :String):
	if name == "disappear":
		reset_position()
		closed.emit()
		visible = false

func reset_position():
	anim_player.play("RESET")

func open():
	visible = true
	anim_player.play("appear")

func close():
	anim_player.play("disappear")
