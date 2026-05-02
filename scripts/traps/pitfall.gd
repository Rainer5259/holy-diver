## Pitfall hazard — instantly defeats the player on contact.
class_name Pitfall
extends Area2D


func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.has_method("fall_into_pit"):
			body.fall_into_pit()
