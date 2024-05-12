extends MeleeUnit
class_name Goblin

func _ready() -> void:
	super()

func add_enemy_to_available_enemies(body: Node2D):
		# Impossible to add range units to enemies.
		if not body is Archer:
			super(body)
