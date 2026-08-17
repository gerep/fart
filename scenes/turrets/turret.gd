extends Node2D

const DEFAULT_BULLET = preload("res://scenes/bullets/bullet.tscn")

@export var rotation_speed: float = 8.0
@export var shot_interval: float = 0.15

@onready var range_area: Area2D = $RangeArea
@onready var range_indicator: Sprite2D = $RangeIndicator

var _has_target := false
var _target: Area2D
var _enemy_queue: Array[Area2D] = []
var _target_global_rotation: float
var _target_position: Vector2
var _is_aiming := false
var _shot_timer := 0.0


func _ready() -> void:
	range_area.area_entered.connect(_area_entered)
	range_area.area_exited.connect(_area_exited)
	_target_global_rotation = global_rotation


func _process(delta: float) -> void:
	if _target != null and not is_instance_valid(_target):
		_clear_target()
		_select_next_target()

	if _has_target:
		_target_position = _target.global_position
		var direction := global_position.direction_to(_target_position)
		_target_global_rotation = direction.angle() + PI / 2.0

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
	if not area is Enemy or _enemy_queue.has(area):
		return

	_enemy_queue.append(area)
	if not _has_target:
		_select_next_target()


func _area_exited(area: Area2D) -> void:
	_enemy_queue.erase(area)

	if area == _target:
		_clear_target()
		_select_next_target()


func _select_next_target() -> void:
	while not _enemy_queue.is_empty():
		var next_target: Area2D = _enemy_queue.pop_front()
		if not is_instance_valid(next_target):
			continue

		_target = next_target
		_has_target = true
		_target_position = next_target.global_position
		var direction := global_position.direction_to(_target_position)
		_target_global_rotation = direction.angle() + PI / 2.0
		_is_aiming = true
		return

	_clear_target()


func _clear_target() -> void:
	_target = null
	_has_target = false
	_is_aiming = false
	_shot_timer = 0.0


func _fire_shot() -> void:
	call_deferred(&"_spawn_bullet", _target_position)
	_shot_timer = maxf(shot_interval, 0.0)


func _spawn_bullet(target_position: Vector2) -> void:
	var bullet: Bullet = DEFAULT_BULLET.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	bullet.setup(target_position)


func set_combat_enabled(enabled: bool) -> void:
	range_area.monitoring = enabled


func set_range_indicator_visible(enabled: bool) -> void:
	range_indicator.visible = enabled
