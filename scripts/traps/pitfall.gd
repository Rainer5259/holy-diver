## Pitfall hazard — instantly defeats the player on contact.
class_name Pitfall
extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("fall_into_pit"):
		body.fall_into_pit()
