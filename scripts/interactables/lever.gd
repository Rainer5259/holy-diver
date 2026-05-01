## Wall lever — toggles its state and emits a signal on the GameEvents bus.
## The right-room lever is wired to open Entrance 1 via entrance_id.
class_name Lever
extends Interactable

@export_group("Lever")
## ID of the entrance/door this lever controls.
@export var entrance_id: StringName = &"entrance_1"
## AnimatedSprite2D showing "off" and "on" frames.
@onready var sprite: Sprite2D = $Sprite2D

## Textures swapped on toggle (assign in the Inspector).
@export var texture_off: Texture2D
@export var texture_on: Texture2D

var _activated: bool = false


func _ready() -> void:
	one_shot = false  # Levers are togglable


func _on_interact(_instigator: Node2D) -> void:
	_activated = !_activated
	if sprite:
		sprite.texture = texture_on if _activated else texture_off

	if _activated:
		GameEvents.entrance_opened.emit(entrance_id)
