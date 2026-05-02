## HUD health bar — listens to GameEvents and updates the ProgressBar.
class_name HealthBar
extends CanvasLayer

@onready var bar: ProgressBar = $MarginContainer/VBoxContainer/HealthBar
@onready var damage_bar: ProgressBar = $MarginContainer/VBoxContainer/DamageBar
@onready var coin_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/CoinLabel
@onready var key_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/KeyLabel
@onready var arrow_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/ArrowLabel


func _ready() -> void:
	GameEvents.player_health_changed.connect(_on_health_changed)
	GameEvents.player_died.connect(_on_player_died)
	GameEvents.coins_changed.connect(_on_coins_changed)
	GameEvents.keys_changed.connect(_on_keys_changed)
	GameEvents.arrows_changed.connect(_on_arrows_changed)
	
	# Initial values
	_on_coins_changed(GameManager.coins)
	_on_keys_changed(GameManager.keys)
	_on_arrows_changed(GameManager.current_arrows)


func _on_coins_changed(new_amount: int) -> void:
	if coin_label:
		coin_label.text = "Moedas: " + str(new_amount)


func _on_keys_changed(new_amount: int) -> void:
	if key_label:
		key_label.text = "Chaves: " + str(new_amount)


func _on_arrows_changed(new_amount: int) -> void:
	if arrow_label:
		arrow_label.text = "Flechas: " + str(new_amount)


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
