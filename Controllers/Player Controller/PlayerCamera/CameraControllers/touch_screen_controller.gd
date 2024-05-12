extends CameraControllerBase

var touch_points: Dictionary = {}
var pinch_data: Dictionary = {}

func _input(event):
	if event is InputEventScreenTouch:
		handle_touch_event(event)
	elif event is InputEventScreenDrag:
		handle_drag_event(event)

func handle_touch_event(event: InputEventScreenTouch):
	if event.pressed:
		touch_points[event.index] = event.position
		
		if touch_points.size() == 2:
			pinch_data["start_distance"] = touch_points.values()[0].distance_to(touch_points.values()[1])
			pinch_data["start_angle"] = get_angle(touch_points.values()[0], touch_points.values()[1])
			pinch_data["start_zoom"] = camera.zoom
		else:
			touch_points.erase(event.index)

func handle_drag_event(event: InputEventScreenDrag):
	touch_points[event.index] = event.position

	if can_pan and touch_points.size() == 1:
		# camera.offset -= event.relative.rotated(camera.rotation) * pan_speed
		camera.position -= event.relative * 2

	elif can_zoom or can_rotate and touch_points.size() == 2:
		var current_positions = touch_points.values()
		var current_distance = current_positions[0].distance_to(current_positions[1])
		var current_angle = get_angle(current_positions[0], current_positions[1])

		if can_zoom:
			camera.zoom = pinch_data["start_zoom"] / (current_distance / pinch_data["start_distance"])
			if can_rotate:
				camera.rotation -= (current_angle - pinch_data["start_angle"]) * rotation_speed
				pinch_data["start_angle"] = current_angle

	limit_zoom()

func get_angle(p1, p2):
	var delta = p2 - p1
	return fmod((atan2(delta.y, delta.x) + PI), (2 * PI))
