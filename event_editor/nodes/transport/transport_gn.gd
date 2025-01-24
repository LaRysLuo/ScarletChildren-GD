## 场景移动节点的VIEW
@tool
extends BaseGN
class_name TransportGN

## INFO 逻辑
## 当选择场景后，获取场景中的可移动点

## 场景选择器
var map_scene_picker:Button:
	get: return get_node("VBoxContainer/Line1/HSplitContainer/Button")


## 选择的场景名
var map_selected:Label:
	get:return get_node("VBoxContainer/Line1/HSplitContainer/Label")

var is_move_character:CheckBox:
	get:return get_node("VBoxContainer/Line4/CheckBox")

var target_vector2i_line:Control:
	get:return get_node("VBoxContainer/Line2")

## 目标点的x
var target_vector2i_x:SpinBox:
	get:return get_node("VBoxContainer/Line2/HSplitContainer/SpinBox")

## 目标点的y
var target_vector2i_y:SpinBox:
	get:return get_node("VBoxContainer/Line2/HSplitContainer/SpinBox2")

## 是否淡入淡出 0是启用 1是禁用	
var is_fade_opt:OptionButton:
	get:return get_node("VBoxContainer/Line3/OptionButton")


var selected_map_path:String = ""
var selected_map_instance:Resource


func _enter_tree() -> void:
	## 输入按钮的初始化
	map_scene_picker.pressed.connect(pick_map_scene)
	is_move_character.pressed.connect(refresh_target_vector2i_line)
	
	refresh_target_vector2i_line()

	

func _exit_tree() -> void:
	map_scene_picker.pressed.disconnect(pick_map_scene)
	is_move_character.pressed.disconnect(refresh_target_vector2i_line)


var scene_picker
var map_root_path := "res://scenes/maps/"

## 根据Line4的CheckBox来判断
func refresh_target_vector2i_line():
	if is_move_character.button_pressed:
		target_vector2i_line.show()
	else: target_vector2i_line.hide()

## 打开窗口，选取地图场景
func pick_map_scene():
	scene_picker = EditorFileDialog.new()
	get_parent().add_child(scene_picker)
	
	scene_picker.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	scene_picker.current_dir = "res://scenes/maps"
	scene_picker.add_filter("Map_*.tscn","RPG配置的地图文件")
	scene_picker.file_selected.connect(on_map_pickered)
	scene_picker.popup_centered(Vector2i(800,600))

func on_map_pickered(path:String):
	print("打开的文件路径是",path)
	if path == null or !path.begins_with(map_root_path):
		show_err("出现错误")
	selected_map_path = path
	refresh_picker_info()

func refresh_picker_info():
	if selected_map_path:
		map_selected.text = selected_map_path.replace(map_root_path,"")
		#selected_map_instance = load(selected_map_path)
	else: map_selected.text = ""
	
	


func set_value(scene_path:String,_is_move_character:bool,target_point:Vector2i,is_fade:bool):
	self.selected_map_path = scene_path
	self.is_move_character.button_pressed = _is_move_character
	self.target_vector2i_x.value = target_point.x
	self.target_vector2i_y.value = target_point.y
	self.is_fade_opt.selected = 0 if is_fade else 1
	refresh_target_vector2i_line()
	refresh_picker_info()

## 当数据有变更时
func on_changed():
	on_value_changed.emit()

func from_data(data:BaseEventNode) -> BaseGN:
	if data is TransportData:
		set_value(data.target_map_path,data.is_move_character,data.target_coord,data.is_fade)
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	## 地图场景路径	
	## 选定的地图坐标
	var x = target_vector2i_x.value
	var y = target_vector2i_y.value
	var is_character_move_value = is_move_character.button_pressed
	var target_point:Vector2i = Vector2i(x,y)
	var is_fade = true if self.is_fade_opt.selected == 0 else false 
	return TransportData.new(BaseEventNode.Transport,self.position_offset,selected_map_path,is_character_move_value,target_point,is_fade)
