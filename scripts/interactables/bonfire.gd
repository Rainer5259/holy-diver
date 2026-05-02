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
	
	# Simulate an upgrade if player has enough coins (for the prototype)
	_auto_upgrade()


func _auto_upgrade() -> void:
	# In a real game, this would be a UI menu
	if GameManager.coins >= health_upgrade_cost:
		if GameManager.upgrade_health(health_upgrade_cost, 20):
			print("Upgraded Health!")
	
	if GameManager.coins >= stamina_upgrade_cost:
		if GameManager.upgrade_stamina(stamina_upgrade_cost, 20.0):
			print("Upgraded Stamina!")
