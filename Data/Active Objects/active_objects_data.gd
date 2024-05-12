extends Resource
class_name ActiveObjectsData

@export var name :String
@export_multiline var description :String
@export var object_scene :PackedScene

# Virtual function to change game data in certain way for each specifis type of BuildableObjects.
# For example: house add N to game food resource. Can be empty if object does nothing.
func impact_game():
	pass
