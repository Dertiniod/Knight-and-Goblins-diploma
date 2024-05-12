extends LevelObject
class_name Zone

signal zone_clicked(zone :Zone)
signal workers_amount_changed(workers: int)
signal income_recalculated(new_incode :int)

@export var income_per_worker: int = 8
@export var available_workers_slots: int = 4
@export var working_timer :Timer = null

var workers :int = 0:
	set(value):
		value = clamp(value, 0, available_workers_slots)
		
		if workers == 0 and value > 0:
			is_zone_working = true
		elif value == workers:
			return
		
		workers = value
		recalculate_income()
		workers_amount_changed.emit(workers)
var income :int:
	set(value):
		income = value
		income_recalculated.emit(income)
var is_zone_working :bool = false:
	set(value):
		if value == true and is_zone_working == false:
			start_working()
		elif value == false and is_zone_working == true:
			stop_working()
		is_zone_working = true

func _ready() -> void:
	input_event.connect(_on_zone_clicked)
	
	working_timer = Timer.new()
	add_child(working_timer)
	
	if is_instance_valid(working_timer):
		# Calculate time for production cycles
		# If 4 timbers - cycle is 15 seconds, so in 60 seconds we get full income
		var production_cycle_time = 60 / available_workers_slots
	
		working_timer.wait_time = production_cycle_time
		working_timer.timeout.connect(_on_work_timer_timeout) 
	
func get_complete_zone_data():
	pass
	
func _on_zone_clicked(viewport :Node, event :InputEvent, shape_idx :int):
	if event.is_action_pressed("click"):
		zone_clicked.emit(self)

func recalculate_income():
	if workers == 0:
		is_zone_working = false
		income = 0
		return
	
	income = workers * income_per_worker

func has_available_slots():
	return available_workers_slots > workers

func earn_resource():
	pass

func _on_work_timer_timeout():
	recalculate_income()
	is_zone_working = workers > 0
	earn_resource()
	
func start_working():
	if working_timer.is_stopped():
		working_timer.start()
	else:
		return

func stop_working():
	working_timer.stop()
