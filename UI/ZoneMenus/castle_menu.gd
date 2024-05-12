extends BottomMenu
class_name CastleMenu

signal knight_button_clicked
signal move_point_clicked

@onready var progress_bar = %KnightProgressBar
@onready var ui_queue = %KnightLabel

@onready var knight_button: TextureButton = $"Control/HBoxContainer/HSplitContainer/Knight Box/KnightButton"
@onready var move_point_button: TextureButton = $"Control/HBoxContainer/HSplitContainer/HBox/Move Point Button"

var knight_data :WarUnitData

func _ready() -> void:
	super()
	button_sprite = $Control/CastleButton/CastleImage
	cancel_sprite = $Control/CastleButton/CancelIcon
	
	if !%CastleButton:
		return
		
	animation_player = $AnimationPlayer
	activate_button = %CastleButton 
	
	knight_button.pressed.connect(_on_knight_button_pressed)
	move_point_button.pressed.connect(_on_move_point_button_pressed)
	activate_button.pressed.connect(_on_active_button_pressed)

func set_units_shop(_game_resources :GameResources, _buyable_units_dic :Dictionary):
	super(_game_resources, _buyable_units_dic)
	
	if buyable_units_dic.has("knight"):
		knight_data = buyable_units_dic["knight"] as WarUnitData 
		
		%KnightGoldLabel.text = str(knight_data.get_cost("gold"))
		%KnightWoodLabel.text = str(knight_data.get_cost("wood"))
		%KnightFoodLabel.text = str(knight_data.get_cost("food"))

func update_units_shop():
	if !knight_data and buyable_units_dic.has("knight"):
		knight_data = buyable_units_dic["knight"] as WarUnitData 
		
		set_labels_modulate(%KnightGoldLabel, game_resources.gold < knight_data.get_cost("gold"))
		set_labels_modulate(%KnightWoodLabel, game_resources.wood < knight_data.get_cost("wood"))
		set_labels_modulate(%KnightFoodLabel, game_resources.get_available_food() < knight_data.get_cost("food"))

func _on_knight_button_pressed():
	if !knight_data:
		print("no knight data in castle menu")
		return
	
	if GameResourcesManager.buy(knight_data):
		unit_button_clicked.emit(knight_data)
	else:
		animation_player.play("knight_error")

func _on_move_point_button_pressed():
	move_point_clicked.emit()
