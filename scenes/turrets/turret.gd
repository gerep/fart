extends Node2D

const DEFAULT_BULLET = preload("res://scenes/bullets/bullet.tscn")

@onready var range_area: Area2D = $RangeArea

var _has_fired := false


func _ready() -> void:
	range_area.area_entered.connect(_area_entered)


func _area_entered(area: Area2D) -> void:
	if _has_fired:
		return

	_has_fired = true
	var target_position := area.global_position
	var direction := global_position.direction_to(target_position)
	rotation = direction.angle() + PI / 2.0
	call_deferred("_spawn_bullet", target_position)


func _spawn_bullet(target_position: Vector2) -> void:
	var bullet: Bullet = DEFAULT_BULLET.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(target_position)


func set_combat_enabled(enabled: bool) -> void:
	range_area.monitoring = enabled
