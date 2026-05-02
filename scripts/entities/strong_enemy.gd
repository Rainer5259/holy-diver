## Smarter enemy with navigation capabilities and higher stats.
class_name StrongEnemy
extends Enemy

@export_group("Strong Enemy")
@export var navigation_update_rate: float = 0.2

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var _nav_timer: float = 0.0


func _ready() -> void:
	super._ready()
	# Strong enemies have more health
	max_health = 100
	current_health = max_health
	move_speed = 65.0
	attack_damage = 25
	coin_drop_count = 5


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
		
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_update_state()
	
	if _state == State.CHASE and is_instance_valid(_target):
		_process_navigation(delta)
	else:
		_process_state(delta)
		
	move_and_slide()


func _process_navigation(delta: float) -> void:
	_nav_timer -= delta
	if _nav_timer <= 0.0:
		nav_agent.target_position = _target.global_position
		_nav_timer = navigation_update_rate
		
	if nav_agent.is_navigation_finished():
		_state = State.ATTACK
		return
		
	var next_path_pos := nav_agent.get_next_path_position()
	var dir := global_position.direction_to(next_path_pos)
	
	velocity = dir * move_speed
	_update_facing(dir)
	_play_animation("walk")
