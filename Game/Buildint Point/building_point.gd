extends Area2D
class_name BuildingPoint

@export var build_popup_scene: PackedScene
@export var building_data :BuildableObjectsData

@onready var build_timer = $BuildTimer
@onready var progress_bar = $ProgressBar

var building_scene: PackedScene
var building_time: float

func _ready():
	if building_data:
		building_data.initialize_data()
		
		building_time = building_data.building_time
		building_scene = building_data.object_scene
		
		progress_bar.max_value = building_time
		build_timer.wait_time = building_time
		build_timer.timeout.connect(on_building_timer_timeout)

func _process(delta):
	if !build_timer.is_stopped():
		var calculated_value = build_timer.wait_time - build_timer.time_left
		progress_bar.value = calculated_value

var popup : BuildPopup
func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click") and popup == null and not is_building:
		popup = build_popup_scene.instantiate()
		popup.start_build.connect(on_start_build)
		
		add_child(popup)
		popup.get_animation_player().play('unfold')
		popup.set_price(building_data)

func buy_building() -> bool:
	var player_controller :PlayerController = GlobalData.player_controller as PlayerController
	if player_controller == null:
		return false
		
	return GameResourcesManager.buy(building_data)

func build():
	is_building = false
	var parent_node = get_parent()
	var building = building_scene.instantiate()
	
	parent_node.add_child(building)
	
	# TODO: Make more generic, so we don't specifically check whether the building is a KnightsHouse.
	if building is KnightsHouse:
		building.house_data = building_data
	
	building.global_position = global_position
	queue_free()

var is_building : bool 
func on_start_build():
	if buy_building():
		popup.animation_player.play('fold')
		is_building = true
		$BuildInProgress.visible = true
		progress_bar.visible = true
		$BuildInProgress/AnimationPlayer.play('Hammer')
		build_timer.start()
	else:
		# HERE WHAT NEEDS TO BE HAPPENING IF NOT ABLE TO BUY
		popup.animation_player.play('error')

func on_building_timer_timeout():
	build()
