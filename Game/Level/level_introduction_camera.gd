extends PathFollow2D

@export var camera_speed :float = 1

var points
var path2D :Path2D
var target_position: Vector2
var current_curve_idx: int = 0

func _ready() -> void:
	choose_target_point()
	$Timer.timeout.connect(func(): choose_target_point())

func choose_target_point():
	current_curve_idx += 1
	
	if current_curve_idx >= path2D.curve.point_count:
		GlobalSignals.level_introduction_finished.emit($Camera2D.global_position)
		await get_tree().create_timer(0.2).timeout
		queue_free()
	
	if path2D.curve.point_count > current_curve_idx:
		target_position = path2D.curve.get_point_position(current_curve_idx)
		print(target_position)

func _physics_process(delta: float) -> void:
	if is_close_to_point($Camera2D.global_position, target_position, 55.0):
		if $Timer.is_stopped():
			$Timer.start()
		return
	else:
		progress_ratio += camera_speed * delta
	
func is_close_to_point(current_position: Vector2, target_point: Vector2, threshold: float) -> bool:
	return current_position.distance_to(target_point) <= threshold

