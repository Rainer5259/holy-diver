## Simple projectile for the bow.
class_name Arrow
extends Area2D

@export var speed: float = 250.0
@export var damage: int = 15
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Rotate the arrow towards the direction
	rotation = direction.angle()
	
	# Auto-destroy after lifetime
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not body.is_in_group(&"player"):
		body.take_damage(damage)
		queue_free()
	elif body.is_in_group(&"environment"):
		queue_free()
