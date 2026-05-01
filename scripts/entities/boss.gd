## Boss enemy — extends Enemy with phase-based behaviour and a mandatory key drop.
class_name Boss
extends Enemy

@export_group("Boss")
## The Key item scene to spawn on death (mandatory; assigned in the editor).
@export var key_scene: PackedScene
@export var phase2_speed_multiplier: float = 1.6
@export var phase2_health_threshold: float = 0.5

var _phase2_active: bool = false


func _ready() -> void:
	super()
	# Bosses are tougher by default; stat scaling is done in the inspector.
	add_to_group(&"boss")


func _physics_process(delta: float) -> void:
	_check_phase_transition()
	super(delta)


func _check_phase_transition() -> void:
	if _phase2_active or _is_dead:
		return
	var ratio := float(current_health) / float(max_health)
	if ratio <= phase2_health_threshold:
		_enter_phase2()


func _enter_phase2() -> void:
	_phase2_active = true
	move_speed *= phase2_speed_multiplier
	# Visual cue — modulate to a reddish tint
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.4, 0.4, 0.4), 0.3)


func _die() -> void:
	# Drop key before calling super (which would queue_free the node)
	if key_scene:
		var key := key_scene.instantiate() as Node2D
		key.global_position = global_position
		get_parent().add_child(key)

	GameEvents.boss_died.emit()
	# Call base die which handles fade and queue_free
	super()
