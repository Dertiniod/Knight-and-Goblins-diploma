extends TextureButton
class_name LevelButton

signal level_button_pressed(level_data :LevelData)

@onready var star_earned_texture :CompressedTexture2D = load("res://Assets/Sprites/UI/Icons/star.png")
@onready var star_not_earned_texture :CompressedTexture2D = load("res://Assets/Sprites/UI/Icons/star_empty.png")

var level_data :LevelData
var star_array :Array[Node]

func _ready() -> void:
	init_star_array()
	pressed.connect(_on_button_pressed)

func init_star_array():
	star_array.push_back(%Star_01)
	star_array.push_back(%Star_02)
	star_array.push_back(%Star_03)

func update_stars(new_level_data :LevelData):
	level_data = new_level_data
	
	if level_data.level_stars > 0:
		%Star_01.texture = star_earned_texture
		if level_data.level_stars > 1:
			%Star_02.texture = star_earned_texture
			if level_data.level_stars > 2:
				%Star_03.texture = star_earned_texture

func _on_button_pressed():
	level_button_pressed.emit(level_data)
