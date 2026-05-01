## Singleton for persistent game state.
## Stores health, stamina, coins, and player evolution.
extends Node

# ── Attributes ───────────────────────────────────────────────────────────────
var max_health: int = 100
var current_health: int = 100

var max_stamina: float = 100.0
var current_stamina: float = 100.0

# ── Progression ──────────────────────────────────────────────────────────────
var coins: int = 0
var level: int = 1


func _ready() -> void:
	# Initialize attributes if needed (e.g., from a save file)
	pass


## Resets attributes to default (e.g., on new game or respawn if desired).
func reset_attributes() -> void:
	current_health = max_health
	current_stamina = max_stamina
	GameEvents.player_health_changed.emit(current_health, max_health)
	GameEvents.player_stamina_changed.emit(current_stamina, max_stamina)
