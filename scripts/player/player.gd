## Player character controller.
## 8-way movement, health system, and E/F interaction detection.
class_name Player
extends CharacterBody2D

# ── Movement ─────────────────────────────────────────────────────────────────
@export_group("Movement")
@export var max_speed: float = 110.0
@export var acceleration: float = 900.0
@export var friction: float = 1200.0

# ── Attributes ───────────────────────────────────────────────────────────────
@export_group("Attributes")
@export var stamina_regen_rate: float = 20.0

var current_health: int:
	set(value):
		current_health = clampi(value, 0, GameManager.max_health)
		GameManager.current_health = current_health
		GameEvents.player_health_changed.emit(current_health, GameManager.max_health)
		if current_health == 0:
			_die()
	get:
		return GameManager.current_health

var current_stamina: float:
	set(value):
		var old_stamina = current_stamina
		current_stamina = clampf(value, 0.0, GameManager.max_stamina)
		GameManager.current_stamina = current_stamina
		GameEvents.player_stamina_changed.emit(current_stamina, GameManager.max_stamina)
		
		if current_stamina <= 0.0 and old_stamina > 0.0:
			GameEvents.player_stamina_depleted.emit()
	get:
		return GameManager.current_stamina

# ── Interaction ──────────────────────────────────────────────────────────────
@export_group("Interaction")
@export var interact_range: float = 40.0

# ── Internal state ───────────────────────────────────────────────────────────
@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea

## Loaded once and cached for direction swaps without redundant disk access.
var _dir_textures: Dictionary = {}
var _last_direction := Vector2.DOWN
var _is_dead: bool = false
var _invincible_timer: float = 0.0
const INVINCIBLE_DURATION := 0.5


func _ready() -> void:
	# Initialize from GameManager
	current_health = GameManager.current_health
	current_stamina = GameManager.current_stamina
	
	add_to_group(&"player")
	_load_direction_textures()


func _load_direction_textures() -> void:
	var base := "res://assets/sprites/player/"
	_dir_textures = {
		"south": load(base + "south.png"),
		"north": load(base + "north.png"),
		"east":  load(base + "east.png"),
		"west":  load(base + "west.png"),
	}
	if _dir_textures["south"]:
		sprite.texture = _dir_textures["south"]


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_invincible_timer = maxf(_invincible_timer - delta, 0.0)
	_handle_stamina_regen(delta)
	_handle_movement(delta)
	_handle_interaction_input()
	move_and_slide()


func _handle_stamina_regen(delta: float) -> void:
	if current_stamina < GameManager.max_stamina:
		current_stamina += stamina_regen_rate * delta


func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
		_last_direction = input_dir
		_update_facing(input_dir)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func _handle_interaction_input() -> void:
	if not Input.is_action_just_pressed("interact"):
		return
	var bodies := interaction_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("interact"):
			body.interact(self)
			break


func _update_facing(direction: Vector2) -> void:
	sprite.flip_h = false
	if absf(direction.x) > absf(direction.y):
		# Dominant horizontal movement
		if direction.x > 0.0:
			sprite.texture = _dir_textures.get("east")
		else:
			sprite.texture = _dir_textures.get("west")
	else:
		# Dominant vertical movement
		if direction.y > 0.0:
			sprite.texture = _dir_textures.get("south")
		else:
			sprite.texture = _dir_textures.get("north")


## Called by pitfall hazard areas.
func fall_into_pit() -> void:
	if _is_dead:
		return
	current_health = 0


## Apply damage with brief invincibility frames.
func take_damage(amount: int) -> void:
	if _is_dead or _invincible_timer > 0.0:
		return
	current_health -= amount
	_invincible_timer = INVINCIBLE_DURATION
	# Flash to indicate hit
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.3, 0.08)
	tween.tween_property(self, "modulate:a", 1.0, 0.08)


## Restore health (from chest loot etc.).
func heal(amount: int) -> void:
	current_health += amount


func _die() -> void:
	_is_dead = true
	velocity = Vector2.ZERO
	GameEvents.player_died.emit()
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.5)
	tween.tween_callback(queue_free)
