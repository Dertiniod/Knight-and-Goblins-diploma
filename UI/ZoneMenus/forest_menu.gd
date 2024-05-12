extends BottomMenu
class_name ForestMenu

signal timber_button_clicked

@onready var forest_button: TextureButton = %ForestButton
@onready var timber_button: TextureButton = %TimberButton
@onready var timber_container: HBoxContainer = $Control/HBoxContainer/WoodProductionVBox/TimberSlots

var timber_data :UnitData
var timber_slots :Array
var timbers_amount :int = 0

func _ready() -> void:
	super()
	animation_player = $AnimationPlayer
	
	set_new_income(0)
	
	timber_button.pressed.connect(_on_timber_button_pressed)
	forest_button.pressed.connect(_on_active_button_pressed)
	
	timber_slots = timber_container.get_children() as Array[Node]

func set_new_income(new_income :int):
	%WoodLabel.text = "0"

	if new_income == 0:
		%WoodLabel.modulate = Color(0.937, 0.318, 0.361)
	elif new_income <= 16 and new_income > 8:
		%WoodLabel.modulate = Color(0.741, 0.843, 0.388)
	elif new_income >= 16:
		%WoodLabel.modulate = Color(0.353, 0.714, 0.349)
	%WoodLabel.text = str(new_income)

func set_units_shop(_game_resources: GameResources, _buyable_units_dic: Dictionary):
	super(_game_resources, _buyable_units_dic)

	if buyable_units_dic.has("timber"):
		timber_data = buyable_units_dic["timber"] as UnitData
		
		%TimberGoldLabel.text = str(timber_data.get_cost("gold"))
		%TimberWoodLabel.text = str(timber_data.get_cost("wood"))
		%TimberFoodLabel.text = str(timber_data.get_cost("food"))

func _on_timber_button_pressed():
	if GameResourcesManager.can_buy(timber_data):
		unit_button_clicked.emit(timber_data)
	else:
		play_error_animation()

func update_units_shop():
	if buyable_units_dic.has("timber"):
		timber_data = buyable_units_dic["timber"] as UnitData
	
	set_labels_modulate(%TimberGoldLabel, game_resources.gold < timber_data.get_cost("gold"))
	set_labels_modulate(%TimberWoodLabel, game_resources.wood < timber_data.get_cost("wood"))
	set_labels_modulate(%TimberFoodLabel, GameResourcesManager.get_available_food() < timber_data.get_cost("food"))
	
	if timbers_amount == 0:
		print("timbers amount can't be 0 now")
		return
		
	if timber_slots.is_empty():
		print("timber slots are emptym what are you even doing here?")
		
	for i in range(timbers_amount):
		var timber_slot :TextureButton = timber_slots[i]
		
		if timber_slot.disabled == false:
			continue
		
		if !timber_slot:
			print("the slot is wrong")
			return
			
		timber_slot.disabled = false
			
		var texture_to_activate :TextureRect = timber_slot.get_child(0)
		if texture_to_activate:
			texture_to_activate.visible = true
			
func set_new_timbers_amount(_timbers_amount :int):
	timbers_amount = _timbers_amount
	update_units_shop()

func play_error_animation():
	if animation_player:
		animation_player.play("knight_error")
