## Shockwave projectile fired by the Fallen Knight boss.
class_name Shockwave
extends Area2D

@export var speed: float = 120.0
@export var damage: int = 20
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Rotate the sprite to face the movement direction
	rotation = direction.angle()
	
	# Destroy after lifetime
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body.collision_layer & 1: # Environment
		queue_free()
