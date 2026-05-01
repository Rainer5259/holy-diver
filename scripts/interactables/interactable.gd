## Abstract base for all interactable objects (chests, levers, doors, etc.).
## Concrete subclasses override _on_interact().
class_name Interactable
extends StaticBody2D

@export var interactable_id: StringName = &""
## If true the object can only be interacted with once.
@export var one_shot: bool = true

var _used: bool = false


## Called by the Player when pressing the interact button within range.
func interact(instigator: Node2D) -> void:
	if one_shot and _used:
		return
	_used = one_shot
	_on_interact(instigator)


## Override in subclasses to implement specific behaviour.
func _on_interact(_instigator: Node2D) -> void:
	pass
