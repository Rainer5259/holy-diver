## Base class for all dungeon enemies.
## Provides patrol/chase AI, health, and death handling.
class_name Enemy
extends CharacterBody2D

# ── Stats ─────────────────────────────────────────────────────────────────────
@export_group("Stats")
@export var max_health: int = 30
@export var move_speed: float = 55.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.2
@export var detection_range: float = 120.0
@export var attack_range: float = 28.0

# ── Drops ─────────────────────────────────────────────────────────────────────
@export_group("Drops")
## Optional scene to instantiate when this enemy dies.
@export var drop_scene: PackedScene = preload("res://scenes/interactables/coin.tscn")
@export var coin_drop_count: int = 1
@export var arrow_drop_chance: float = 0.3
@export var arrow_scene: PackedScene = preload("res://scenes/interactables/arrow_pickup.tscn")

# ── Internals ─────────────────────────────────────────────────────────────────
@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

var current_health: int
var _attack_timer: float = 0.0
var _target: Node2D = null
var _is_dead: bool = false

enum State { PATROL, CHASE, ATTACK, DEAD }
var _state: State = State.PATROL
var _patrol_direction: Vector2 = Vector2.RIGHT
var _patrol_timer: float = 0.0


func _ready() -> void:
	current_health = max_health
	_randomise_patrol()


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_update_state()
	_process_state(delta)
	move_and_slide()


func _update_state() -> void:
	match _state:
		State.PATROL:
			var player := _find_player_in_range(detection_range)
			if player:
				_target = player
				_state = State.CHASE
		State.CHASE:
			if not is_instance_valid(_target):
				_state = State.PATROL
				return
			var dist := position.distance_to(_target.position)
			if dist <= attack_range:
				_state = State.ATTACK
			elif dist > detection_range * 1.5:
				_target = null
				_state = State.PATROL
		State.ATTACK:
			if not is_instance_valid(_target):
				_state = State.PATROL
				return
			var dist := position.distance_to(_target.position)
			if dist > attack_range:
				_state = State.CHASE


func _process_state(delta: float) -> void:
	match _state:
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase()
		State.ATTACK:
			_do_attack()
			velocity = Vector2.ZERO


func _do_patrol(delta: float) -> void:
	_patrol_timer -= delta
	if _patrol_timer <= 0.0:
		_randomise_patrol()

	velocity = _patrol_direction * (move_speed * 0.4)
	_update_facing(_patrol_direction)
	_play_animation("walk")


func _do_chase() -> void:
	if not is_instance_valid(_target):
		return
	var dir := position.direction_to(_target.position)
	velocity = dir * move_speed
	_update_facing(dir)
	_play_animation("walk")


func _do_attack() -> void:
	_play_animation("idle")
	if _attack_timer <= 0.0 and is_instance_valid(_target):
		if _target.has_method("take_damage"):
			_target.take_damage(attack_damage)
		_attack_timer = attack_cooldown


func _find_player_in_range(range_px: float) -> Node2D:
	for body in detection_area.get_overlapping_bodies():
		if body.is_in_group(&"player"):
			if position.distance_to(body.position) <= range_px:
				return body as Node2D
	return null


func _randomise_patrol() -> void:
	_patrol_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	_patrol_timer = randf_range(1.5, 3.5)


func _update_facing(direction: Vector2) -> void:
	if absf(direction.x) > 0.1:
		sprite.flip_h = direction.x < 0.0


func _play_animation(_anim_name: StringName) -> void:
	pass  # Sprite2D — animations handled externally when SpriteFrames are available


## Receive damage from the player or a trap.
func take_damage(amount: int) -> void:
	if _is_dead:
		return
	current_health = clampi(current_health - amount, 0, max_health)
	if current_health == 0:
		_die()


func _die() -> void:
	_is_dead = true
	_state = State.DEAD
	velocity = Vector2.ZERO
	set_physics_process(false)
	GameEvents.enemy_died.emit(self)

	if drop_scene:
		for i in range(coin_drop_count):
			var drop := drop_scene.instantiate() as Node2D
			get_parent().add_child(drop)
			drop.global_position = global_position
			
	if randf() < arrow_drop_chance and arrow_scene:
		var arrows := arrow_scene.instantiate() as Node2D
		get_parent().add_child(arrows)
		arrows.global_position = global_position

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)
