class_name PlayerCamera
extends Camera2D

## Smooth camera that follows the parent node with configurable lookahead.
@export_group("Smoothing")
@export var follow_smoothing: float = 5.0
@export var lookahead_strength: float = 16.0
@export var lookahead_smoothing: float = 3.0

var _lookahead_offset := Vector2.ZERO


func _ready() -> void:
	position_smoothing_enabled = false


func _physics_process(delta: float) -> void:
	var parent := get_parent() as CharacterBody2D
	if not parent:
		return

	var target_lookahead := parent.velocity.normalized() * lookahead_strength
	_lookahead_offset = _lookahead_offset.lerp(target_lookahead, lookahead_smoothing * delta)
	offset = offset.lerp(_lookahead_offset, follow_smoothing * delta)
