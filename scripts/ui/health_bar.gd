## HUD health bar — listens to GameEvents and updates the ProgressBar.
class_name HealthBar
extends CanvasLayer

@onready var bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var damage_bar: ProgressBar = $MarginContainer/VBoxContainer/DamageBar


func _ready() -> void:
	GameEvents.player_health_changed.connect(_on_health_changed)
	GameEvents.player_died.connect(_on_player_died)


func _on_health_changed(current: int, maximum: int) -> void:
	bar.max_value = maximum
	bar.value = current
	damage_bar.max_value = maximum
	# Damage bar lags behind for a visual bleed effect
	var tween := create_tween()
	tween.tween_property(damage_bar, "value", current, 0.4).set_delay(0.2)


func _on_player_died() -> void:
	# Optionally flash the bar red on death
	var tween := create_tween()
	tween.tween_property(bar, "modulate", Color(1.5, 0.2, 0.2), 0.15)
	tween.tween_property(bar, "modulate", Color.WHITE, 0.15)
