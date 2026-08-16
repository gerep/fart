extends Node2D

const DEFAULT_BULLET = preload("res://scenes/bullets/bullet.tscn")

@export var rotation_speed: float = 8.0

@onready var range_area: Area2D = $RangeArea

var _has_fired := false
var _target_global_rotation: float
var _target_position: Vector2
var _is_aiming := false


func _ready() -> void:
	range_area.area_entered.connect(_area_entered)
	_target_global_rotation = global_rotation


func _process(delta: float) -> void:
	global_rotation = lerp_angle(
		global_rotation,
		_target_global_rotation,
		rotation_speed * delta
	)

	if _is_aiming and absf(angle_difference(global_rotation, _target_global_rotation)) < 0.05:
		_is_aiming = false
		call_deferred("_spawn_bullet", _target_position)


func _area_entered(area: Area2D) -> void:
	if _has_fired:
		return

	_has_fired = true
	_target_position = area.global_position
	var direction := global_position.direction_to(_target_position)
	_target_global_rotation = direction.angle() + PI / 2.0
	_is_aiming = true


func _spawn_bullet(target_position: Vector2) -> void:
	var bullet: Bullet = DEFAULT_BULLET.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(target_position)


func set_combat_enabled(enabled: bool) -> void:
	range_area.monitoring = enabled
