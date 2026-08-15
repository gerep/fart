extends Node2D
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var buildable_layer: TileMapLayer = $BuildableLayer

var _buildable_cells: Array[Vector2i] = []


func _ready() -> void:
	GameManager.build_mode.connect(_on_build_mode)


func _on_build_mode(enabled: bool) -> void:
	_buildable_cells.clear()
	buildable_layer.clear()

	if not enabled:
		return

	var overlay_source_id := buildable_layer.tile_set.get_source_id(0)

	for cell: Vector2i in tile_map_layer.get_used_cells():
		var cell_data := tile_map_layer.get_cell_tile_data(cell)
		if cell_data == null or cell_data.get_custom_data("buildable") != true:
			continue

		_buildable_cells.append(cell)
		var atlas_coords := tile_map_layer.get_cell_atlas_coords(cell)
		buildable_layer.set_cell(cell, overlay_source_id, atlas_coords, 0)
