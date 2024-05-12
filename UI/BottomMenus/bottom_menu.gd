extends CanvasLayer
class_name BottomMenu

signal open_bottom_menu(bottom_menu :BottomMenu)
signal unit_button_clicked(unit_data :UnitData)

@export var hint :PackedScene
@export var button_sprite :TextureRect
@export var cancel_sprite :TextureRect
@export var main_window :HBoxContainer

var activate_button: TextureButton
var buyable_units_dic: Dictionary
var menu_opened: bool = false
var is_being_opened: bool = false
var game_resources: GameResources
var animation_player: AnimationPlayer:
	set(value):
		animation_player = value
		if is_instance_valid(animation_player):
			animation_player.animation_finished.connect(_on_animation_finished)

func _ready() -> void:
	disable_buttons()

func enable_buttons():
	if main_window:
		main_window.visible = true

func disable_buttons():
	if main_window:
		main_window.visible = false

func show_main_icon():
	if !button_sprite || !cancel_sprite:
		return
	button_sprite.visible = true
	cancel_sprite.visible = false
	
func show_cancel_icon():
	if !button_sprite || !cancel_sprite:
		return
	button_sprite.visible = false
	cancel_sprite.visible = true

func _on_animation_finished(animation_name :String):
	is_being_opened = false

func set_units_shop(_game_resources: GameResources, _buyable_units_dic: Dictionary):
	game_resources = _game_resources
	buyable_units_dic = _buyable_units_dic

func choose_sprite():
	if !button_sprite or !cancel_sprite:
		return
	
	if menu_opened:
		button_sprite.visible = false
		cancel_sprite.visible = true
	else:
		button_sprite.visible = true
		cancel_sprite.visible = false

func _on_active_button_pressed():
	if !is_being_opened:
		owner.open_or_close_menus(self)
		
		if !menu_opened:
			is_being_opened = true
	pass

func update_units_shop():
	pass
	
func open_menu():
	if menu_opened:
		return
	
	menu_opened = true
	var menu_anim_to_play = "menu_appear"
	var hint_anim_to_play = "appear"
	
	if is_instance_valid(animation_player):
		animation_player.play(menu_anim_to_play)
	if is_instance_valid(hint):
		hint.animation_player.play(hint_anim_to_play)
		
	open_bottom_menu.emit(self)

func close_menu():
	if !menu_opened:
		return
	
	menu_opened = false
	var menu_anim_to_play = "menu_disappear"
	var hint_anim_to_play = "disappear"
	
	if is_instance_valid(animation_player):
		animation_player.play(menu_anim_to_play)
	if is_instance_valid(hint):
		hint.animation_player.play(hint_anim_to_play)
	
	open_bottom_menu.emit(self)

func set_labels_modulate(label :Label, is_over_limit :bool):
	if is_over_limit:
		label.modulate = Color(0.714, 0.333, 0.333)
	else:
		label.modulate = Color(1, 1, 1)
