extends Controller
class_name PlayerController

@export var castle_menu_scene :PackedScene
@export var forest_menu_scene :PackedScene
@export var hud_scene :PackedScene
@export var move_point_hint_scene: PackedScene
@export var controlled_zones :Array[Zone]
@export var interactables :Array[ActiveObject]
@export var dropdown_menus_manager :DropdownMenusManager

@onready var hint = move_point_hint_scene.instantiate()
@onready var bottom_menu_manager: BottomMenuManager = $BottomMenuManager

@onready var castle_menu: CastleMenu = $BottomMenuManager/CastleMenu
@onready var forest_menu: ForestMenu = $BottomMenuManager/ForestMenu

var hud :HUD
var game_resources :GameResources
var is_castle_menu_opened :bool = false:
	set(value):
		is_castle_menu_opened = value
		if castle_menu:
			castle_menu.menu_opened = is_castle_menu_opened
var is_setting_new_move_point = false
var forest_zone :ForestZone

func _init() -> void:
	set_process_unhandled_input(false)
	GlobalData.set_player_controller(self)
	
	GlobalSignals.game_won.connect(func(): open_menu(GameEnums.DROPDOWN_MENU_TYPE.WIN))
	GlobalSignals.game_lost.connect(func(): open_menu(GameEnums.DROPDOWN_MENU_TYPE.LOSE))
	
func init_player_camera(new_position :Vector2):
	$PlayerCamera.global_position = new_position
	%PlayerCamera.correct_zoom()
	
func show_ui():
	hud.visible = true
	forest_menu.visible = true
	castle_menu.visible = true
	
func initialize_controller():
	super()
	
	set_process_unhandled_input(true)
	
	$PlayerCamera.enabled = true
	
	bottom_menu_manager.show_menus()
	
	game_resources = GameResourcesManager.get_game_resources()
	
	for unit_name in available_units_data:
		var unit_data :UnitData = available_units_data[unit_name]
		if available_units_data[unit_name] is UnitData:
			unit_data.initialize_data()
	
	hud = hud_scene.instantiate() as HUD
	hud.menu_button_pressed.connect(_on_hud_menu_button_pressed)
	
	add_child(hud)
	hud.set_resources_ui(game_resources)
	
	add_child(hint)
	
	if dropdown_menus_manager:
		dropdown_menus_manager.menu_closed.connect(_on_dropdown_menu_closed)
	
	bottom_menu_manager.init_menues(game_resources, available_units_data)
	
	spawn_component.unit_is_being_trained.connect(_on_unit_is_being_trained)
	spawn_component.spawn_menu = castle_menu
	
	game_resources.resources_changed.connect(_on_game_resources_value_changed)
	hud.set_resources_ui(game_resources)
	
	hud.visible = false
	forest_menu.visible = false
	castle_menu.visible = false
	
	for zone in controlled_zones:
		zone.zone_clicked.connect(_on_zone_clicked)
		
		if zone is ForestZone:
			forest_zone = zone
			forest_zone.workers_amount_changed.connect(_on_timber_amount_change)
			forest_zone.income_recalculated.connect(_on_forest_income_recalculated)

func update_preparation_time(new_values :Vector2):
	if is_instance_valid(hud):
		hud.update_countdown_values(new_values)

func _on_dropdown_menu_closed():
	resume_game()

func open_menu(menu_type :GameEnums.DROPDOWN_MENU_TYPE):
	if !dropdown_menus_manager:
		return
	
	if !dropdown_menus_manager.has_menu(menu_type):
		return
	
	pause_game()
	
	if dropdown_menus_manager:
		dropdown_menus_manager.switch_menu_to(menu_type)

func pause_game():
	bottom_menu_manager.hide_menus()
	hud.visible = false
	get_tree().paused = true

func resume_game():
	bottom_menu_manager.show_menus()
	hud.visible = true
	get_tree().paused = false
	
func _on_hud_menu_button_pressed(menu_type :GameEnums.DROPDOWN_MENU_TYPE):
	open_menu(menu_type)

func _on_forest_income_recalculated(new_income):
	forest_menu.set_new_income(new_income)

func _on_timber_button_clicked(timber_data :UnitData):
	if !forest_zone:
		return
	elif !forest_zone.has_available_slots():
		forest_menu.play_error_animation()
		return
		
	forest_zone.workers += 1
	GameResourcesManager.buy(timber_data)

func _on_timber_amount_change(timber_amount :int):
	forest_menu.set_new_timbers_amount(timber_amount)

func _on_zone_clicked(zone :Zone):
	if zone is ForestZone:
		bottom_menu_manager.open_or_close_menus(forest_menu)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") && is_setting_new_move_point:
		is_setting_new_move_point = false
		
		for knight in get_tree().get_nodes_in_group("knights"):
			if knight is MeleeUnit:
				knight.set_new_move_point_position()
		set_move_point_position(get_global_mouse_position())
	
	if event.is_action_pressed("interact"):
		get_fake_resources()

func set_move_point_position(new_position :Vector2):
	if move_point != null:
		move_point.global_position = new_position
	else:
		print("no move point were assigned to ", name)
		get_tree().quit()

func _on_move_point_clicked():
	is_setting_new_move_point = true

func open_bottom_menu(bottom_menu :BottomMenu):
	if bottom_menu is CastleMenu:
		main_building.is_castle_clicked = castle_menu.menu_opened
	
func add_active_object_to_controller(new_object: ActiveObject):
	new_object.active_object_clicked.connect(_on_active_object_clicked)
	interactables.push_back(new_object)

func _on_game_resources_value_changed(resource_type :GameResources.ResourceType, has_grown :bool):
	hud.set_res_ui_by_type(resource_type, has_grown)
	castle_menu.update_units_shop()

func _on_unit_is_being_trained(is_knight_being_trained):
	main_building.play_animations(!is_knight_being_trained)

func _on_knight_button_clicked(unit_data :UnitData):
	start_unit_spawning(available_units_data["knight"])

func _on_wave_changed(wave_number :int):
	hud.change_wave_number(wave_number)

func _on_controlled_unit_died(dead_unit :Unit):
	game_resources.food -= dead_unit.unit_data.food

func _on_open_bottom_menu_clicked(bottom_menu :BottomMenu):
	open_bottom_menu(bottom_menu)

func _on_active_object_clicked(object :ActiveObject):
	if object is Castle:
		bottom_menu_manager.open_or_close_menus(castle_menu)

# HELPERS
func get_fake_resources():
	game_resources.wood += 100
	game_resources.gold += 100
#func decrease_fake_resources():
#	game_resources.wood -= 100
#	game_resources.gold -= 100
