## Pickable coin that provides currency.
class_name Coin
extends Node2D

@export var value: int = 5
@export var attract_speed: float = 300.0
@export var attract_range: float = 60.0

var _is_collected: bool = false
var _player: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D


func _ready() -> void:
	# Jump animation on spawn
	var target_pos := position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:x", target_pos.x, 0.4).set_trans(Tween.TRANS_SINE)
	
	var jump_tween := create_tween()
	jump_tween.tween_property(sprite, "position:y", -16, 0.2).set_trans(Tween.TRANS_QUAD)
	jump_tween.tween_property(sprite, "position:y", 0, 0.2).set_trans(Tween.TRANS_QUAD)
	
	area.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	if _is_collected:
		return
		
	if not _player:
		_player = _find_player()
		
	if _player:
		var dist := global_position.distance_to(_player.global_position)
		if dist <= attract_range:
			global_position = global_position.move_toward(_player.global_position, attract_speed * delta)
			if dist <= 10.0:
				_collect()


func _find_player() -> Node2D:
	var players = get_tree().get_nodes_in_group(&"player")
	if players.size() > 0:
		return players[0] as Node2D
	return null


func _on_body_entered(body: Node) -> void:
	if body.is_in_group(&"player"):
		_collect()


func _collect() -> void:
	if _is_collected:
		return
	_is_collected = true
	
	GameManager.coins += value
	
	# Visual and sound (sound skipped for now)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.finished.connect(queue_free)
