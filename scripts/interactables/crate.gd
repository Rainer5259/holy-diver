## Simple crate that can be opened or broken.
class_name Crate
extends Interactable

@export_group("Crate")
@export var loot_scene: PackedScene = preload("res://scenes/interactables/coin.tscn")
@export var loot_count: int = 3
@export var is_breakable: bool = true

@onready var sprite: Sprite2D = $Sprite2D


func _on_interact(_instigator: Node2D) -> void:
	_open()


func _open() -> void:
	if _used:
		return
	_used = true
	
	# Visual effect (squash/stretch then disappear)
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_property(sprite, "scale", Vector2(0.0, 0.0), 0.2)
	tween.finished.connect(_spawn_loot)


func _spawn_loot() -> void:
	if loot_scene:
		for i in range(loot_count):
			var loot = loot_scene.instantiate() as Node2D
			get_parent().add_child(loot)
			loot.global_position = global_position
	
	GameEvents.object_broken.emit(interactable_id)
	queue_free()


## Can be called by weapons to break the crate.
func take_damage(_amount: int) -> void:
	if is_breakable:
		_open()
