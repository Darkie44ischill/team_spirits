extends CanvasLayer

@onready var label = $HeartDisplay/HeartLabel

func update_hearts(current_health: int) -> void:
	label.text = "x" + str(current_health)
