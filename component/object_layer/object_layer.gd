@tool
extends TileMapLayer
class_name ObjectLayer




func _on_visibility_changed() -> void:
	if self.visible:
		_refresh_coord_hint()
	pass # Replace with function body.

func _refresh_coord_hint():
	for coord:Vector2i in get_used_cells():
		var tile:TileData = get_cell_tile_data(coord)
	pass
