## Floor spike trap with a configurable on/off cycle.
## "Active Trap 2s" in the map has a 2-second active phase before retracting.
class_name Trap
extends Area2D

@export_group("Trap Timing")
## Seconds the spikes stay retracted (safe to cross).
@export var safe_duration: float = 2.0
## Seconds the spikes stay extended (dangerous).
@export var active_duration: float = 2.0
## Start in the extended (active) state.
@export var start_active: bool = false

@export_group("Damage")
@export var damage_per_tick: int = 15
@export var damage_interval: float = 0.5

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

## Textures swapped based on active state (set via inspector or preloaded).
@export var texture_idle: Texture2D
@export var texture_active: Texture2D
@onready var cycle_timer: Timer = $CycleTimer
@onready var damage_timer: Timer = $DamageTimer

var _is_active: bool = false
var _bodies_inside: Array[Node2D] = []


func _ready() -> void:
	_is_active = start_active
	_apply_state()

	cycle_timer.timeout.connect(_on_cycle_timeout)
	damage_timer.timeout.connect(_on_damage_timeout)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	cycle_timer.start(active_duration if _is_active else safe_duration)


func _on_cycle_timeout() -> void:
	_is_active = !_is_active
	_apply_state()
	cycle_timer.start(active_duration if _is_active else safe_duration)


func _apply_state() -> void:
	if sprite:
		if _is_active and texture_active:
			sprite.texture = texture_active
		elif not _is_active and texture_idle:
			sprite.texture = texture_idle
	# Defer collision toggle so physics state remains consistent
	set_deferred("monitoring", _is_active)
	collision.set_deferred("disabled", not _is_active)

	if _is_active and not _bodies_inside.is_empty():
		damage_timer.start(damage_interval)
	else:
		damage_timer.stop()


func _on_body_entered(body: Node2D) -> void:
	if not _is_active:
		return
	if body.has_method("take_damage"):
		_bodies_inside.append(body)
		damage_timer.start(damage_interval)


func _on_body_exited(body: Node2D) -> void:
	_bodies_inside.erase(body)
	if _bodies_inside.is_empty():
		damage_timer.stop()


func _on_damage_timeout() -> void:
	for body in _bodies_inside.duplicate():
		if is_instance_valid(body) and body.has_method("take_damage"):
			body.take_damage(damage_per_tick)
		else:
			_bodies_inside.erase(body)
