extends Node2D

@export_range(1, 100, 1) var enemy_count: int = 5
@export var enemy_spawn_interval: float = 0.75
@export_range(0, 100, 1) var enemy_count_growth: int = 2
@export_range(1, 100, 1) var base_health: int = 10

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var buildable_layer: TileMapLayer = $BuildableLayer
@onready var placement_preview: Node2D = $PlacementPreview
@onready var path: Path2D = $Path2D
@onready var turrets: Node2D = $Turrets
@onready var enemies: Node2D = $Enemies
@onready var defeat_panel: Control = $CanvasLayer/DefeatPanel
@onready var restart_button: Button = $CanvasLayer/DefeatPanel/CenterContainer/PanelContainer/MarginContainer/HBoxContainer/RestartButton

const TURRET = preload("uid://crp8t36tadjcf")
const ENEMY = preload("res://scenes/enemies/enemy.tscn")

var _buildable_cells: Array[Vector2i] = []
var _occupied_cells: Dictionary = {}
var _is_building: bool = false
var _is_game_over: bool = false
var _wave_active: bool = false
var _is_spawning: bool = false
var _wave_number: int = 0
var _remaining_enemies: int = 0
var _preview_turret: Node2D


func _ready() -> void:
	GameManager.build_mode.connect(_on_build_mode)
	GameManager.base_health_changed.emit(base_health)
	GameManager.wave_start_requested.connect(_start_wave)
	GameManager.wave_number_changed.emit(_wave_number)
	GameManager.wave_state_changed.emit(false)
	restart_button.pressed.connect(_restart_game)


func _start_wave() -> void:
	if _wave_active or _is_game_over:
		return

	_wave_number += 1
	_wave_active = true
	_remaining_enemies = 0
	GameManager.wave_number_changed.emit(_wave_number)
	GameManager.wave_state_changed.emit(true)
	_spawn_wave()


func _spawn_wave() -> void:
	_is_spawning = true
	var wave_enemy_count := enemy_count + (_wave_number - 1) * enemy_count_growth

	for index in wave_enemy_count:
		if _is_game_over:
			_is_spawning = false
			return

		_remaining_enemies += 1
		_spawn_enemy()

		if index < wave_enemy_count - 1:
			await get_tree().create_timer(enemy_spawn_interval).timeout

	_is_spawning = false
	_check_wave_complete()


func _spawn_enemy() -> void:
	var enemy: Enemy = ENEMY.instantiate()
	enemy.speed = randf_range(enemy.speed * 0.8, enemy.speed * 1.2)
	enemy.escaped.connect(_on_enemy_escaped)
	enemy.died.connect(_on_enemy_died)
	enemies.add_child(enemy)
	enemy.setup(path)


func _on_enemy_escaped() -> void:
	if _is_game_over:
		return

	base_health -= 1
	GameManager.base_health_changed.emit(base_health)
	_enemy_removed_from_wave()

	if base_health <= 0:
		_game_over()


func _on_enemy_died() -> void:
	_enemy_removed_from_wave()


func _enemy_removed_from_wave() -> void:
	_remaining_enemies -= 1
	_check_wave_complete()


func _check_wave_complete() -> void:
	if not _wave_active or _is_spawning or _remaining_enemies > 0:
		return

	_wave_active = false
	GameManager.wave_state_changed.emit(false)


func _game_over() -> void:
	_is_game_over = true
	_on_build_mode(false)
	enemies.process_mode = Node.PROCESS_MODE_DISABLED
	turrets.process_mode = Node.PROCESS_MODE_DISABLED
	defeat_panel.visible = true


func _restart_game() -> void:
	get_tree().reload_current_scene()


func _process(_delta: float) -> void:
	if not _is_building:
		return

	var cell := _get_mouse_cell()
	var snapped_position := _get_cell_world_position(cell)
	_preview_turret.global_position = snapped_position
	_preview_turret.modulate = Color(0.5, 1.0, 0.5, 0.7) if _is_cell_available(cell) else Color(1.0, 0.4, 0.4, 0.7)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _is_building:
		_on_build_mode(false)
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and _is_building:
		_try_place_turret()


func _on_build_mode(enabled: bool) -> void:
	if _is_building == enabled:
		return

	_is_building = enabled
	GameManager.build_mode_changed.emit(_is_building)
	_remove_place_preview_turret()
	_buildable_cells.clear()
	buildable_layer.clear()

	if not enabled:
		return

	_place_preview_turret()

	var overlay_source_id := buildable_layer.tile_set.get_source_id(0)

	for cell: Vector2i in tile_map_layer.get_used_cells():
		var cell_data := tile_map_layer.get_cell_tile_data(cell)
		if cell_data == null or cell_data.get_custom_data("buildable") != true:
			continue

		_buildable_cells.append(cell)
		if _occupied_cells.has(cell):
			continue

		var atlas_coords := tile_map_layer.get_cell_atlas_coords(cell)
		buildable_layer.set_cell(cell, overlay_source_id, atlas_coords, 0)


func _get_mouse_cell() -> Vector2i:
	return tile_map_layer.local_to_map(tile_map_layer.to_local(get_global_mouse_position()))


func _get_cell_world_position(cell: Vector2i) -> Vector2:
	return tile_map_layer.to_global(tile_map_layer.map_to_local(cell))


func _is_cell_available(cell: Vector2i) -> bool:
	return _buildable_cells.has(cell) and not _occupied_cells.has(cell)


func _try_place_turret() -> void:
	var cell := _get_mouse_cell()
	if not _is_cell_available(cell):
		return

	var turret: Node2D = TURRET.instantiate()
	turrets.add_child(turret)
	turret.global_position = _get_cell_world_position(cell)
	_occupied_cells[cell] = turret
	buildable_layer.erase_cell(cell)


func _place_preview_turret() -> void:
	_preview_turret = TURRET.instantiate()
	placement_preview.add_child(_preview_turret)
	_preview_turret.call("set_combat_enabled", false)
	_preview_turret.call("set_range_indicator_visible", true)


func _remove_place_preview_turret() -> void:
	if _preview_turret == null:
		return

	_preview_turret.queue_free()
	_preview_turret = null
