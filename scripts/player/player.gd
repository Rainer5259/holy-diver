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
@export var sword_damage: int = 15
@export var sword_cooldown: float = 0.4
@export var dodge_stamina_cost: float = 30.0
@export var attack_stamina_cost: float = 15.0
@export var shoot_stamina_cost: float = 20.0

# ── Combat ───────────────────────────────────────────────────────────────────
@export_group("Combat")
@export var arrow_scene: PackedScene
@export var dodge_speed_mult: float = 2.5
@export var dodge_duration: float = 0.25

var current_health: int:
	set(value):
		var new_health = clampi(value, 0, GameManager.max_health)
		if GameManager.current_health != new_health:
			GameManager.current_health = new_health
			GameEvents.player_health_changed.emit(new_health, GameManager.max_health)
			if new_health == 0:
				_die()
	get:
		return GameManager.current_health

var current_stamina: float:
	set(value):
		var old_stamina = GameManager.current_stamina
		var new_stamina = clampf(value, 0.0, GameManager.max_stamina)
		if old_stamina != new_stamina:
			GameManager.current_stamina = new_stamina
			GameEvents.player_stamina_changed.emit(new_stamina, GameManager.max_stamina)
			if new_stamina <= 0.0 and old_stamina > 0.0:
				GameEvents.player_stamina_depleted.emit()
	get:
		return GameManager.current_stamina

# ── Interaction ──────────────────────────────────────────────────────────────
@export_group("Interaction")
@export var interact_range: float = 40.0

# ── Internal state ───────────────────────────────────────────────────────────
@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea

var _is_dodging: bool = false
var _is_attacking: bool = false
var _dodge_timer: float = 0.0
var _attack_timer: float = 0.0

## Loaded once and cached for direction swaps without redundant disk access.
var _dir_textures: Dictionary = {}
var _last_direction := Vector2.DOWN
var _is_dead: bool = false
var _invincible_timer: float = 0.0
const INVINCIBLE_DURATION := 0.5


func _ready() -> void:
	add_to_group(&"player")
	_load_direction_textures()
	
	# The attributes are already in GameManager, no need to re-initialize local vars
	# as they use getters/setters that point to GameManager.


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
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_handle_stamina_regen(delta)
	
	if not _is_dodging:
		_handle_combat_input()
		_handle_movement(delta)
		_handle_interaction_input()
	else:
		_process_dodge(delta)
		
	move_and_slide()


func _handle_combat_input() -> void:
	if _is_attacking or _attack_timer > 0.0:
		return
		
	if Input.is_action_just_pressed("dodge") and current_stamina >= dodge_stamina_cost:
		_start_dodge()
	elif Input.is_action_just_pressed("attack") and current_stamina >= attack_stamina_cost:
		_perform_sword_attack()
	elif Input.is_action_just_pressed("shoot") and current_stamina >= shoot_stamina_cost:
		_perform_bow_attack()


func _start_dodge() -> void:
	current_stamina -= dodge_stamina_cost
	_is_dodging = true
	_dodge_timer = dodge_duration
	_invincible_timer = dodge_duration # I-frames during dodge
	
	# Visual feedback for dodge
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.5, 0.1)
	tween.finished.connect(func(): sprite.modulate.a = 1.0)


func _process_dodge(delta: float) -> void:
	_dodge_timer -= delta
	velocity = _last_direction * (max_speed * dodge_speed_mult)
	if _dodge_timer <= 0.0:
		_is_dodging = false
		velocity = Vector2.ZERO


func _perform_sword_attack() -> void:
	current_stamina -= attack_stamina_cost
	_is_attacking = true
	_attack_timer = sword_cooldown
	
	# Sword attack logic: check for enemies in front
	var overlap_bodies = interaction_area.get_overlapping_bodies()
	
	for body in overlap_bodies:
		if body.is_in_group(&"enemies") and body.has_method("take_damage"):
			# Simple check if enemy is in front (based on _last_direction)
			var to_enemy = (body.global_position - global_position).normalized()
			if to_enemy.dot(_last_direction) > 0.3: # ~70 degrees cone
				body.take_damage(sword_damage)
		elif body is Crate:
			body.take_damage(sword_damage)
	
	# Visual feedback
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	tween.finished.connect(func(): _is_attacking = false)


func _perform_bow_attack() -> void:
	if not arrow_scene:
		_is_attacking = false
		return
		
	current_stamina -= shoot_stamina_cost
	_is_attacking = true
	_attack_timer = sword_cooldown # Share cooldown for now
	
	var arrow = arrow_scene.instantiate() as Arrow
	arrow.global_position = global_position
	arrow.direction = _last_direction
	get_parent().add_child(arrow)
	
	# Visual feedback
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.8, 1.2), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	tween.finished.connect(func(): _is_attacking = false)


func _handle_stamina_regen(delta: float) -> void:
	if not _is_dodging and not _is_attacking and current_stamina < GameManager.max_stamina:
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
	
	_is_dead = true
	velocity = Vector2.ZERO
	
	# Fall animation
	var tween := create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.5)
	tween.tween_property(sprite, "rotation", TAU, 0.5)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	
	tween.chain().tween_callback(func():
		current_health = 0
	)


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
