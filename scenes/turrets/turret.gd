extends Node2D

const DEFAULT_BULLET = preload("res://scenes/bullets/bullet.tscn")

@export var rotation_speed: float = 8.0
@export var shot_interval: float = 0.15

@onready var range_area: Area2D = $RangeArea

var _has_fired := false
var _has_target := false
var _target: Area2D
var _target_global_rotation: float
var _target_position: Vector2
var _is_aiming := false
var _shot_timer := 0.0


func _ready() -> void:
	range_area.area_entered.connect(_area_entered)
	range_area.area_exited.connect(_area_exited)
	_target_global_rotation = global_rotation


func _process(delta: float) -> void:
	global_rotation = lerp_angle(
		global_rotation,
		_target_global_rotation,
		rotation_speed * delta
	)

	if _is_aiming and absf(angle_difference(global_rotation, _target_global_rotation)) < 0.05:
		_is_aiming = false
		_shot_timer = 0.0

	if _has_target and not _is_aiming:
		_shot_timer -= delta
		if _shot_timer <= 0.0:
			_fire_shot()


func _area_entered(area: Area2D) -> void:
	if _has_fired:
		return

	_has_fired = true
	_has_target = true
	_target = area
	_target_position = area.global_position
	var direction := global_position.direction_to(_target_position)
	_target_global_rotation = direction.angle() + PI / 2.0
	_is_aiming = true


func _area_exited(area: Area2D) -> void:
	if area != _target:
		return

	_target = null
	_has_fired = false
	_has_target = false
	_is_aiming = false
	_shot_timer = 0.0
	call_deferred("_find_new_target")


func _find_new_target() -> void:
	if _has_target:
		return

	for area: Area2D in range_area.get_overlapping_areas():
		_area_entered(area)
		return


func _fire_shot() -> void:
	call_deferred("_spawn_bullet", _target_position)
	_shot_timer = maxf(shot_interval, 0.0)


func _spawn_bullet(target_position: Vector2) -> void:
	var bullet: Bullet = DEFAULT_BULLET.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(target_position)


func set_combat_enabled(enabled: bool) -> void:
	range_area.monitoring = enabled
