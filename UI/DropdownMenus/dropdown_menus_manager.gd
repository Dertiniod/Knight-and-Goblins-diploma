extends Node2D
class_name DropdownMenusManager

signal menu_closed

var menus_dic :Dictionary
var current_menu :DropdownMenu

func _ready():
	fill_menus_dic()

func has_menu(menu_type :GameEnums.DROPDOWN_MENU_TYPE):
	return menus_dic.has(menu_type)

func fill_menus_dic():
	for menu in get_children():
		menus_dic[menu.type] = menu as DropdownMenu
		menu.closed.connect(_on_menu_closed)
		
		if menu is PauseMenu:
			menu.resume_game_clicked.connect(_on_resume_game_pressed)
			menu.settings_clicked.connect(_on_settings_pressed)
			menu.exit_clicked.connect(_on_exit_pressed)
		elif menu is SettingsPauseMenu:
			menu.return_to_pause.connect(_on_return_to_menu_pressed)
		elif menu is GameFinishMenu:
			menu.back_to_menu_clicked.connect(_on_exit_pressed)
			menu.restart_level_clicked.connect(_on_restart_level_clicked)

func _on_menu_closed():
	current_menu = null
	menu_closed.emit()

func open_new_menu(menu_type :GameEnums.DROPDOWN_MENU_TYPE):
	if menus_dic.has(menu_type):
		current_menu = menus_dic[menu_type] as DropdownMenu
		current_menu.open()

func switch_menu_to(menu_type :GameEnums.DROPDOWN_MENU_TYPE):
	if !current_menu:
		open_new_menu(menu_type)
		return
	
	if current_menu.type == menu_type:
		return
	
	for menu in menus_dic:
		if menus_dic[menu].type == menu_type:
			menus_dic[menu].visible = true
			current_menu = menus_dic[menu]
		else:
			menus_dic[menu].visible = false

func _on_resume_game_pressed():
	current_menu.close()

func _on_return_to_menu_pressed():
	switch_menu_to(GameEnums.DROPDOWN_MENU_TYPE.PAUSE)

func _on_exit_pressed():
	GlobalSignals.return_to_main_menu_requested.emit()
	
func _on_restart_level_clicked():
	GlobalSignals.restart_game_requested.emit()
	
func _on_settings_pressed():
	switch_menu_to(GameEnums.DROPDOWN_MENU_TYPE.SETTINGS)
