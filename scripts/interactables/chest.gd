## Interactive chest — requires a key to open, then grants loot.
class_name Chest
extends Interactable

@export_group("Chest")
@export var requires_key: bool = false
@export var heal_amount: int = 25

@onready var sprite: Sprite2D = $Sprite2D

## Textures to swap (assign in the Inspector).
@export var texture_closed: Texture2D
@export var texture_open: Texture2D


func _on_interact(instigator: Node2D) -> void:
	if requires_key:
		if GameManager.keys <= 0:
			return
		GameManager.keys -= 1

	if sprite and texture_open:
		sprite.texture = texture_open

	if instigator.has_method("heal"):
		instigator.heal(heal_amount)

	GameEvents.chest_opened.emit(interactable_id)
