extends Control
class_name BottomMenuManager

@export var player_controller :PlayerController

@onready var castle_menu: CastleMenu = $CastleMenu
@onready var forest_menu: ForestMenu = $ForestMenu

var are_menues_opened :bool = false

func _ready() -> void:
	hide_menus()

func init_menues(game_res: GameResources, buyable_units: Dictionary):
	forest_menu_init(game_res, buyable_units)
	castle_menu_init(game_res, buyable_units)

func show_menus():
	castle_menu.visible = true
	forest_menu.visible = true

func hide_menus():
	castle_menu.visible = false
	forest_menu.visible = false

func forest_menu_init(game_res: GameResources, buyable_units: Dictionary):
	if !forest_menu || !player_controller:
		return
		
	forest_menu.open_bottom_menu.connect(player_controller._on_open_bottom_menu_clicked)
	forest_menu.unit_button_clicked.connect(player_controller._on_timber_button_clicked)
	forest_menu.set_units_shop(game_res, buyable_units)

func castle_menu_init(game_res: GameResources, buyable_units: Dictionary):
	if !castle_menu || !player_controller:
		return

	castle_menu.unit_button_clicked.connect(player_controller._on_knight_button_clicked)
	castle_menu.open_bottom_menu.connect(player_controller._on_open_bottom_menu_clicked)
	castle_menu.move_point_clicked.connect(player_controller._on_move_point_clicked)
	
	castle_menu.set_units_shop(game_res, buyable_units)
	
	castle_menu.animation_player.play('start_game')
	castle_menu.progress_bar.visible = false


var front_menu: BottomMenu = null

func open_or_close_menus(menu_clicked: BottomMenu):
	if are_menues_opened and menu_clicked != front_menu:
		switch_between_menus(menu_clicked)
		return

	are_menues_opened = not are_menues_opened

	if are_menues_opened:
		switch_between_menus(menu_clicked)
		castle_menu.open_menu()
		forest_menu.open_menu()
	else:
		castle_menu.close_menu()
		forest_menu.close_menu()
		if is_instance_valid(front_menu):
			front_menu.show_main_icon()

func switch_between_menus(new_front_menu: BottomMenu):
	if is_instance_valid(front_menu):
		front_menu.show_main_icon()
		front_menu.disable_buttons()
		
	front_menu = new_front_menu
	front_menu.enable_buttons()
	
	move_child(front_menu, front_menu.get_index() + 1)
	front_menu.show_cancel_icon()
