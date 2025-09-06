extends Area2D

@export var heal_amount := 1


func _on_body_entered(body: Node2D) -> void:
		if body is CharacterBody2D and body.has_method("heal"):
			body.heal(heal_amount)
			queue_free()
