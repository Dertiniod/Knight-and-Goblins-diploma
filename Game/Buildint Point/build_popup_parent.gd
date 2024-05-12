extends Node2D
class_name BuildPopup

signal start_build

@onready var animation_player = $AnimationPlayer
@onready var food_label: Label = %"Food Label"
@onready var gold_label: Label = %"Gold Label"
@onready var wood_label: Label = %"Wood Label"

var game_resources :GameResources
var building_data :BuildableObjectsData

var update_time = 0.2
var counter = 0.0

func _on_build_button_pressed():
	start_build.emit()

func _on_cancel_button_pressed():
	animation_player.play("fold")

func get_animation_player():
	if animation_player != null:
		return animation_player

func set_price(_building_data :BuildableObjectsData):
	if _building_data == null:
		return
	building_data = _building_data as BuildableObjectsData
	
	var player_controller :PlayerController = GlobalData.player_controller as PlayerController
	if player_controller == null:
		return
		
	game_resources = player_controller.game_resources as GameResources
	if !game_resources.resources_changed.is_connected(_on_resources_changed):
		game_resources.resources_changed.connect(_on_resources_changed)
		update_prices()
	
	var gold = building_data.get_cost("gold")
	var food = building_data.get_cost("food")
	var wood = building_data.get_cost("wood")
	
	food_label.text = str(food)
	gold_label.text = str(gold)
	wood_label.text = str(wood)
	
	if gold <= 0:
		%"Gold HContainer".visible = false
	if food <= 0:
		%"Food HContainer".visible = false
	if wood <= 0:
		%"Wood HContainer".visible = false

func _on_resources_changed(resource_type :GameResources.ResourceType, has_grown :bool):
	update_prices()

func update_prices():
	if building_data == null or game_resources == null:
		return
		
	var gold_price = building_data.get_cost("gold")
	var wood_price = building_data.get_cost("wood")
	
	var available_gold = game_resources.gold
	var available_wood = game_resources.wood
	
	var food_price = building_data.get_cost("food")
	var available_food = GameResourcesManager.get_available_food()
	
	set_labels_modulate(gold_label, gold_price <= available_gold)
	set_labels_modulate(wood_label, wood_price <= available_wood)
	set_labels_modulate(food_label, food_price <= available_food)

func set_labels_modulate(label :Label, has_funds :bool):
	if !has_funds:
		label.modulate = Color(0.714, 0.333, 0.333)
	else:
		label.modulate = Color(1, 1, 1)
