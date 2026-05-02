## Global signal bus — autoloaded as GameEvents.
## All systems communicate through here to stay decoupled.
extends Node

# @warning_ignore_start("unused_signal")
## Player signals
signal player_health_changed(current: int, maximum: int)
signal player_stamina_changed(current: float, maximum: float)
signal player_stamina_depleted()
signal player_died()

## Interactable signals
signal entrance_opened(entrance_id: StringName)
signal entrance_closed(entrance_id: StringName)
signal key_collected()
signal chest_opened(chest_id: StringName)
signal object_broken(object_id: StringName)
signal bonfire_rested()

## Enemy signals
signal enemy_died(enemy: Node2D)
signal boss_died()
# @warning_ignore_restore("unused_signal")
