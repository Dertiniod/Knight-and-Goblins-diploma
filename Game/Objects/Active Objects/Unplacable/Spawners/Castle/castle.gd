extends SpawnerObject
class_name Castle

@export var castle_menu: PackedScene

@onready var sprite_shader = $Sprite2D.material

@onready var animation_sprites = $AnimationSprites
@onready var animation_player = $AnimationPlayer

var move_point :MovePoint
var is_castle_clicked :bool = false

func _ready():
	super()
	input_event.connect(_on_input_event)
	
	animation_sprites.visible = false
	sprite_shader.set_shader_parameter('width', 0)

#func _process(delta):
	#check_outline()
	
func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		active_object_clicked.emit(self)
		check_outline()
	
func check_outline():
	if is_castle_clicked:
		sprite_shader.set_shader_parameter('width', 3)
	elif !is_castle_clicked:
		sprite_shader.set_shader_parameter('width', 0)

func play_animations(should_play_training_anim :bool):
	if should_play_training_anim:
		animation_sprites.visible = false
		animation_player.stop()
	else:
		animation_sprites.visible = true
		animation_player.play("knight_training")
