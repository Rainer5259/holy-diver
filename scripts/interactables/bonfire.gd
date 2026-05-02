## Bonfire interactable — Saves the game and heals the player.
## Represents the "Evolução" (Evolution) point.
class_name Bonfire
extends Interactable

@export_group("Bonfire")
@export var health_upgrade_cost: int = 50
@export var stamina_upgrade_cost: int = 50


func _ready() -> void:
	one_shot = false # Can rest multiple times


func _on_interact(instigator: Node2D) -> void:
	# Heal player
	if instigator.has_method("heal"):
		instigator.heal(GameManager.max_health)
	
	# Save progress
	GameManager.save_game()
	
	# Emit event for UI or other systems
	GameEvents.bonfire_rested.emit()
