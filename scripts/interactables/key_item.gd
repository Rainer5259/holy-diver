## Collectible key dropped by the boss.
## Auto-collected when the player walks over it.
class_name KeyItem
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collect_tween: Tween


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Subtle bob animation
	var bob := create_tween().set_loops()
	bob.tween_property(sprite, "position:y", -4.0, 0.6).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(sprite, "position:y", 0.0, 0.6).set_ease(Tween.EASE_IN_OUT)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player"):
		return
	GameManager.keys += 1
	GameEvents.key_collected.emit()
	set_deferred("monitoring", false)

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)
