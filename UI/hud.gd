extends CanvasLayer
class_name HUD

signal menu_button_pressed(menu_scene :PackedScene)

@onready var gold_label: Label = %"Gold Label"
@onready var food_label: Label = %"Food Label"
@onready var wood_label: Label = %"Wood Label"
@onready var waves_label: Label = %"Waves Label"
@onready var waves_limit_label: Label = %"Waves Limit Label"
@onready var food_limit_label: Label = %"Food Limit"

func _ready() -> void:
	%Pause.hud_button_pressed.connect(_on_hud_button_pressed)
	%Sound.hud_button_pressed.connect(_on_hud_button_pressed)
	%Shop.hud_button_pressed.connect(_on_hud_button_pressed)
	
	GlobalSignals.wave_preparation_started.connect(func(): start_timer_countdown())
	GlobalSignals.wave_preparation_finished.connect(func(): finish_timer_countdown())
	GlobalSignals.wave_started.connect(func(wave_info :WaveData): set_alert_text(wave_info))

func _on_hud_button_pressed(menu_type):
	menu_button_pressed.emit(menu_type)

func set_wave_limit(new_limit):
	waves_limit_label.text = str(new_limit)

func change_wave_number(wave_number :int):
	waves_label.text = str(wave_number) + "/"

func set_res_ui_by_type(res_type :GameResources.ResourceType, has_grown :bool):
	var game_resources = GameResourcesManager.game_resources
	var label_to_change :Label
	var is_over_limit :bool
	
	match res_type:
		GameResources.ResourceType.GOLD:
			var gold :int = game_resources.gold
			gold_label.text = str(game_resources.gold)
			label_to_change = gold_label
			is_over_limit = gold >= 999
		GameResources.ResourceType.WOOD:
			var wood :int = game_resources.wood
			wood_label.text = str(game_resources.wood)
			label_to_change = wood_label
			is_over_limit = wood >= 999
		GameResources.ResourceType.FOOD:
			var food_limit :int = game_resources.food_limit
			var food :int = game_resources.food
			food_label.text = str(food)
			label_to_change = food_label
			is_over_limit = food >= game_resources.food_limit
		GameResources.ResourceType.DEFAULT:
			label_to_change = %'Food Limit'
			label_to_change.text = str(game_resources.food_limit)
			is_over_limit = false
			
	show_change(label_to_change, has_grown)
	await get_tree().create_timer(0.1).timeout
	set_labels_modulate(label_to_change, is_over_limit)

func show_change(label_to_change, has_grown):
	if has_grown:
		label_to_change.modulate = Color(0.353, 0.714, 0.349)
	else:
		label_to_change.modulate = Color(0.714, 0.333, 0.333)

func set_resources_ui(game_resources :GameResources):
	if game_resources == null:
		print("resources are not valid (UI)")
		return
	
	var gold :int = game_resources.gold
	var food :int = game_resources.food
	var wood :int = game_resources.wood
	var food_limit :int = game_resources.food_limit
	
	%"Food Limit".text = str(food_limit)
	
	set_labels_modulate(gold_label, gold >= 999)
	set_labels_modulate(wood_label, wood >= 999)
	
	gold_label.text = str(game_resources.gold)
	wood_label.text = str(game_resources.wood)
	
	set_labels_modulate(food_label, food >= game_resources.food_limit)
	food_label.text = str(game_resources.food)

func set_labels_modulate(label :Label, is_over_limit :bool):
	if is_over_limit:
		label.modulate = Color(0.714, 0.333, 0.333)
	else:
		label.modulate = Color(1, 1, 1)

func set_alert_text(wave_info :WaveData):
	$Alert/TextureRect/HBoxContainer/Label.text = "The wave number " + str(wave_info.wave_number)
	$Alert/TextureRect/HBoxContainer/Label2.text = " has just started!"
	
	start_wave()

func start_wave():
	$Alert/AnimationPlayer.play("start_wave_alert")

func finish_timer_countdown():
	%AnimationPlayer.play("wave_timer_finished")

func start_timer_countdown():
	%AnimationPlayer.play("wave_timer_start")

func update_countdown_values(new_values :Vector2):
	var minutes :int = new_values.x
	var seconds :int = new_values.y
	
	%WaveTime.text = str(minutes) + ":" + str(seconds)
