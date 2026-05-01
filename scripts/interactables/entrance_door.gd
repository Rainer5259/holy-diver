## Entrance door / wall segment that slides open when a lever signals it.
class_name EntranceDoor
extends StaticBody2D

@export var entrance_id: StringName = &"entrance_1"

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var _is_open: bool = false


func _ready() -> void:
	GameEvents.entrance_opened.connect(_on_entrance_opened)


func _on_entrance_opened(id: StringName) -> void:
	if id != entrance_id or _is_open:
		return
	_open()


func _open() -> void:
	_is_open = true
	collision.set_deferred("disabled", true)

	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func() -> void: sprite.visible = false)
