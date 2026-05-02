## Bonfire Menu UI — Allows player to buy upgrades.
class_name BonfireMenu
extends CanvasLayer

@onready var coin_label: Label = %CoinLabel
@onready var health_button: Button = %HealthUpgradeButton
@onready var stamina_button: Button = %StaminaUpgradeButton
@onready var exit_button: Button = %ExitButton

@export var health_upgrade_cost: int = 50
@export var stamina_upgrade_cost: int = 50
@export var health_increment: int = 20
@export var stamina_increment: float = 20.0

func _ready() -> void:
	# Hide by default
	visible = false
	
	# Connect signals
	GameEvents.bonfire_rested.connect(_on_bonfire_rested)
	GameEvents.coins_changed.connect(_on_coins_changed)
	
	health_button.pressed.connect(_on_health_pressed)
	stamina_button.pressed.connect(_on_stamina_pressed)
	exit_button.pressed.connect(close)
	
	_update_ui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		close()
		get_viewport().set_input_as_handled()


func _on_bonfire_rested() -> void:
	open()


func open() -> void:
	visible = true
	get_tree().paused = true
	_update_ui()


func close() -> void:
	visible = false
	get_tree().paused = false


func _update_ui() -> void:
	coin_label.text = "Moedas: " + str(GameManager.coins)
	health_button.text = "Upgrade Vida (+%d) - Custo: %d" % [health_increment, health_upgrade_cost]
	stamina_button.text = "Upgrade Estamina (+%d) - Custo: %d" % [int(stamina_increment), stamina_upgrade_cost]
	
	# Disable buttons if not enough coins
	health_button.disabled = GameManager.coins < health_upgrade_cost
	stamina_button.disabled = GameManager.coins < stamina_upgrade_cost


func _on_health_pressed() -> void:
	if GameManager.upgrade_health(health_upgrade_cost, health_increment):
		_update_ui()


func _on_stamina_pressed() -> void:
	if GameManager.upgrade_stamina(stamina_upgrade_cost, stamina_increment):
		_update_ui()


func _on_coins_changed(_new_amount: int) -> void:
	if visible:
		_update_ui()
