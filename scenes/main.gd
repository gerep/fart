extends Node2D

@export_range(1, 100, 1) var enemy_count: int = 5
@export var enemy_spawn_interval: float = 0.75
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
var _preview_turret: Node2D


func _ready() -> void:
	GameManager.build_mode.connect(_on_build_mode)
	GameManager.base_health_changed.emit(base_health)
	restart_button.pressed.connect(_restart_game)
	_spawn_enemies()


func _spawn_enemies() -> void:
	for index in enemy_count:
		if _is_game_over:
			return

		_spawn_enemy()

		if index < enemy_count - 1:
			await get_tree().create_timer(enemy_spawn_interval).timeout


func _spawn_enemy() -> void:
	var enemy: Enemy = ENEMY.instantiate()
	enemy.speed = randf_range(enemy.speed * 0.8, enemy.speed * 1.2)
	enemy.escaped.connect(_on_enemy_escaped)
	enemies.add_child(enemy)
	enemy.setup(path)


func _on_enemy_escaped() -> void:
	if _is_game_over:
		return

	base_health -= 1
	GameManager.base_health_changed.emit(base_health)

	if base_health <= 0:
		_game_over()


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


func _remove_place_preview_turret() -> void:
	if _preview_turret == null:
		return

	_preview_turret.queue_free()
	_preview_turret = null
