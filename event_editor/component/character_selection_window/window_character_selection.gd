@tool

extends Control
class_name WindowCharacterSelection
var grid:
	get():return get_node("VBoxContainer")

signal on_selection_complete

## 游戏数据
var characters_data:Array:
	get():return get_characters()
	
func _enter_tree() -> void:
	print("初始化了")
	add_option({
		"label":"本事件",
		"coord":"this",
	})
	add_option({
		"label":"玩家",
		"coord":"player",
	})
	if characters_data.is_empty():return
	for char in characters_data:
		add_option(char)
	#self.show()

## 渲染选项
func add_option(item):
	var char_name = item['label']
	var coord  =  item['coord']
	var value = ""
	var btn:Button = Button.new()
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	grid.add_child(btn)
	if typeof(coord) == TYPE_VECTOR2I: value =  coord
	btn.text = char_name + str(value) 
	btn.button_down.connect(on_selected.bind(item))
	
func on_selected(item):
	on_selection_complete.emit(item)
	
	pass

func get_characters():
	var resut = []
	var node = EditorInterface.get_edited_scene_root()
	var path = "./Maps/Objects"
	if !node.has_node(path):
		print_debug("错误！现在编辑的窗口不是游戏地图")
		return
	var event_tilelayer = node.get_node(path)
	if !event_tilelayer : return
	if event_tilelayer is TileMapLayer:
		var coord_group = event_tilelayer.get_used_cells()
		for coord in coord_group:
			var scene:PackedScene = get_scene_source(event_tilelayer,coord)
			var file_name = scene.resource_path.get_file().get_basename()
			var true_name = get_character_name(file_name)
			if true_name: 
				resut.append({
					"coord": coord,
					"label": true_name
				})
	return resut

func get_character_name(file_name:StringName):
	var arr = file_name.split("_")
	if(arr[0] == 'character'):
		return arr[1]
	else: return file_name

func get_scene_source(tile_map_layer:TileMapLayer,coord:Vector2i):
	var source_id = tile_map_layer.get_cell_source_id(coord)
	if source_id > -1:
		var scene_source = tile_map_layer.tile_set.get_source(source_id)
		if scene_source is TileSetScenesCollectionSource:
			var alt_id = tile_map_layer.get_cell_alternative_tile(coord)
			print("alt_id=",alt_id)
			# 分配的 PackedScene。
			return scene_source.get_scene_tile_scene(alt_id)
	return null
