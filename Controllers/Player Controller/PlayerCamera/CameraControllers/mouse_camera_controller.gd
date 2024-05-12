extends CameraControllerBase


@export var zoom_factor := 0.1
@export var zoom_duration := 0.2

var zoom_level := 1.0


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE && can_pan: 
			camera.position -= event.relative * 2
			
	var zoom_direction = Input.get_axis("scroll_down", "scroll_up")
	if zoom_direction != 0 && can_zoom:
		set_zoom_level(zoom_level + zoom_factor * zoom_direction)
			
	#if event.is_action_pressed("zoom_down"):
	#	set_zoom_level(zoom_level - zoom_factor)
	#if event.is_action_pressed("zoom_up"):
	#	set_zoom_level(zoom_level + zoom_factor)


func set_zoom_level(value: float) -> void:
	zoom_level = clamp(value, min_zoom, max_zoom)
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(zoom_level, zoom_level), zoom_duration)
	tween.play()
