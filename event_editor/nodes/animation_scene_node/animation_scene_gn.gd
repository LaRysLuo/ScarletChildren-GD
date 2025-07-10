@tool
extends BaseGN
class_name AnimationSceneGN


## 组件引用
# 场景选择器
var map_scene_picker:Button:
	get: return get_node("VBoxContainer/HSplitContainer3/HSplitContainer/Button")

var preview_label:Label:
	get:return get_node("VBoxContainer/HSplitContainer3/HSplitContainer/Label")

var scene_picker:EditorFileDialog

## 属性
var map_path:String

func _enter_tree() -> void:
	map_scene_picker.pressed.connect(pick_map_scene)

func _exit_tree() -> void:
	map_scene_picker.pressed.disconnect(pick_map_scene)

## 打开窗口，选取地图场景
func pick_map_scene():
	scene_picker = EditorFileDialog.new()
	get_parent().add_child(scene_picker)
	
	scene_picker.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	scene_picker.current_dir = "res://scenes/maps"
	scene_picker.add_filter("*.tscn","RPG配置的动画场景文件")
	scene_picker.file_selected.connect(on_map_pickered)
	scene_picker.popup_centered(Vector2i(800,600))

func on_map_pickered(path:String):
	print("打开的文件路径是",path)
	if path == null: show_err("出现错误")
	map_path = path
	refresh_picker_info()

func refresh_picker_info():
	if map_path:
		var file_name = map_path.get_file().get_basename()
		preview_label.text = file_name
		#selected_map_instance = load(selected_map_path)
	else: preview_label.text = "无"

func from_data(data:BaseEventNode) -> BaseGN:
	if data is AnimationSceneData:
		map_path = data.animation_scene_path
		refresh_picker_info()
	return self

func to_data(_edit:GraphEdit) -> BaseEventNode:
	return AnimationSceneData.new(BaseEventNode.PlayAnimationScene,self.position_offset,map_path)
	
