## Area 1 Boss: The Fallen Knight.
## Heavy frontal attacks with long telegraphs to teach dodging.
class_name FallenKnight
extends Boss

@export_group("Fallen Knight")
@export var telegraph_duration: float = 1.3
@export var shockwave_scene: PackedScene
@export var shockwave_count: int = 3

var _is_telegraphing: bool = false


func _ready() -> void:
	super._ready()
	# Fallen Knight specific stats
	max_health = 300
	current_health = max_health
	move_speed = 40.0
	attack_damage = 30
	attack_range = 45.0
	attack_cooldown = 3.0


func _do_attack() -> void:
	if _is_telegraphing:
		return
		
	_start_telegraph()


func _start_telegraph() -> void:
	_is_telegraphing = true
	_attack_timer = attack_cooldown
	
	# Visual telegraph: Flash and shake
	var tween := create_tween().set_loops(3)
	tween.tween_property(sprite, "modulate", Color(2.0, 0.5, 0.5), 0.25)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	
	var shake_tween := create_tween().set_loops(int(telegraph_duration / 0.1))
	shake_tween.tween_property(sprite, "offset:x", 2.0, 0.05)
	shake_tween.tween_property(sprite, "offset:x", -2.0, 0.05)
	
	# After telegraph, perform the actual attack
	get_tree().create_timer(telegraph_duration).timeout.connect(_perform_boss_attack)


func _perform_boss_attack() -> void:
	_is_telegraphing = false
	sprite.offset.x = 0
	
	if _is_dead:
		return
		
	# Frontal smash
	if is_instance_valid(_target):
		var dist := global_position.distance_to(_target.global_position)
		if dist <= attack_range * 1.2:
			var dir_to_target = ( _target.global_position - global_position).normalized()
			# We assume the boss is facing the target since it was chasing it
			if _target.has_method("take_damage"):
				_target.take_damage(attack_damage)
	
	# Fire shockwaves in phase 2 or as a regular attack
	_fire_shockwaves()
	
	# Screenshake effect (handled by camera if available)
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("apply_shake"):
		camera.apply_shake(10.0)


func _fire_shockwaves() -> void:
	if not shockwave_scene or not is_instance_valid(_target):
		return
		
	var base_dir := global_position.direction_to(_target.global_position)
	var spread := PI / 6 # 30 degrees
	
	var count = shockwave_count
	if _phase2_active:
		count += 2
		
	for i in range(count):
		var angle = (float(i) - (count-1)/2.0) * (spread / max(1, count-1))
		var dir = base_dir.rotated(angle)
		
		var sw = shockwave_scene.instantiate() as Shockwave
		sw.global_position = global_position
		sw.direction = dir
		get_parent().add_child(sw)
