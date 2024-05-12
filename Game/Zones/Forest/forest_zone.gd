extends Zone
class_name ForestZone

@onready var axe: Axe = $CuttingTree

var zone_size :Vector2

func _ready() -> void:
	super()
	zone_size = Vector2(100.0, 300.0)
	axe.make_cut.connect(on_axe_cut)

func earn_resource():
	super()
	var add_income :int = income / available_workers_slots
	GameResourcesManager.earn_wood(add_income)

var cut_position :Vector2
func on_axe_cut():
	cut_position = global_position + get_alternating_random_point(zone_size.x, zone_size.y)
	axe.global_position = cut_position

func start_working():
	super()
	$CuttingTree.start_cutting_animation()

# This function alternates between returning a random point from the left to the center
# and from the center to the right, along the x-axis, each time it is called.
var toggle = false
func get_alternating_random_point(x, y):
	# Static variable to store the toggle state
	# Toggle the state each time the function is called
	toggle = !toggle
	
	# Define the range for x based on the toggle state
	var min_x = 0 if toggle else x / 2
	var max_x = x / 2 if toggle else x
	
	# Generate a random X coordinate within the defined range
	var random_x = randi_range(min_x, max_x)
	# Generate a random Y coordinate between 0 and y
	var random_y = randi_range(0, y / 2)
	
	# Return the random point as a Vector2
	return Vector2(random_x, random_y)
