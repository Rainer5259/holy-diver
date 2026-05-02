## HUD stamina bar — listens to GameEvents and updates its display.
class_name StaminaBar
extends Control

@onready var bar: ProgressBar = $ProgressBar

func _ready() -> void:
	GameEvents.player_stamina_changed.connect(_on_stamina_changed)
	GameEvents.player_stamina_depleted.connect(_on_stamina_depleted)


func _on_stamina_changed(current: float, maximum: float) -> void:
	bar.max_value = maximum
	bar.value = current


func _on_stamina_depleted() -> void:
	# Flash the bar to indicate it's empty
	var tween := create_tween()
	tween.tween_property(bar, "modulate", Color(1.0, 0.0, 0.0), 0.1)
	tween.tween_property(bar, "modulate", Color.WHITE, 0.1)
