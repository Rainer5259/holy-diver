## Singleton for persistent game state.
## Stores health, stamina, coins, and player evolution.
extends Node

# ── Attributes ───────────────────────────────────────────────────────────────
var max_health: int = 100
var current_health: int = 100

var max_stamina: float = 100.0
var current_stamina: float = 100.0

# ── Persistence ──────────────────────────────────────────────────────────────
const SAVE_PATH = "user://savegame.cfg"


## Saves the current state to a config file.
func save_game() -> void:
	var config = ConfigFile.new()
	config.set_value("Player", "max_health", max_health)
	config.set_value("Player", "max_stamina", max_stamina)
	config.set_value("Progression", "coins", coins)
	config.set_value("Progression", "level", level)
	config.save(SAVE_PATH)


## Loads the state from the config file.
func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		max_health = config.get_value("Player", "max_health", 100)
		max_stamina = config.get_value("Player", "max_stamina", 100.0)
		coins = config.get_value("Progression", "coins", 0)
		level = config.get_value("Progression", "level", 1)
		
		# Reset current attributes to max on load
		current_health = max_health
		current_stamina = max_stamina


# ── Progression ──────────────────────────────────────────────────────────────
func upgrade_health(cost: int, amount: int) -> bool:
	if coins >= cost:
		coins -= cost
		max_health += amount
		current_health = max_health
		GameEvents.player_health_changed.emit(current_health, max_health)
		return true
	return false


func upgrade_stamina(cost: int, amount: float) -> bool:
	if coins >= cost:
		coins -= cost
		max_stamina += amount
		current_stamina = max_stamina
		GameEvents.player_stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false


## Resets attributes to default (e.g., on new game or respawn if desired).
func reset_attributes() -> void:
	current_health = max_health
	current_stamina = max_stamina
	GameEvents.player_health_changed.emit(current_health, max_health)
	GameEvents.player_stamina_changed.emit(current_stamina, max_stamina)
