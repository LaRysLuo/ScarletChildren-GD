## 消息节点的VIEW
@tool
extends BaseGN
class_name MessageGNV2

@export var wait_type_btn:OptionButton 
@export var wait_time_line:Control

var dialogue_input_pre = preload("res://event_editor/component/dialogue_input.tscn")
const WINDOQW_DEFAULT_HEIGHT= 414
const DIALOGUE_INPUT_HEIGHT = 180

var role_picker_window

var role_selected:Role

## 角色选择器
var role_picker_btn:Button:
	get: return get_node("VBoxContainer/Line1/HSplitContainer/Button")

## 选择的角色名
var role_selected_text:Label:
	get:return get_node("VBoxContainer/Line1/HSplitContainer/Label")


## 选项选择框
var option_btn:OptionButton:
	get: return get_node("VBoxContainer/HSplitContainer/OptionButton")

## 数字输入框
var spin_box:SpinBox:
	get: return get_node("VBoxContainer/HSplitContainer2/SpinBox")



var position_type:OptionButton:
	get: return get_node("VBoxContainer/HSplitContainer5/OptionButton")

## 对话文本输入grid
var dialogue_input_grid:VBoxContainer:
	get: return get_node("VBoxContainer/Control/HBoxContainer/VBoxContainer")

var dialogue_input_add_btn:Button:
	get: return get_node("VBoxContainer/Control/HSplitContainer/Button")


func _enter_tree() -> void:
	wait_type_btn = $VBoxContainer/HSplitContainer/OptionButton
	wait_time_line = $VBoxContainer/HSplitContainer2
	wait_time_line.hide()
	
	## 输入按钮的初始化
	wait_type_btn.item_selected.connect(_on_item_selected)
	
	# spin_box.changed.connect(on_changed)
	
	role_picker_btn.pressed.connect(_on_role_picked)

	## 对话输入框得初始化
	_init_dialogue_input()

## 初始化对话输入框
func _init_dialogue_input():
	var dialogue_input:DialogueInput = _get_default_dialogue_input()
	print("[MeesageGNCp]dialogue_input=%s" % typeof(dialogue_input))

	# if dialogue_input.has_method("disable_del"):
	# 	print("有这个函数，disable_del")
	# 	dialogue_input.disable_del()
	dialogue_input_add_btn.pressed.connect(_add_dialogue_input)
	# var dialugue_input = dialogue_input_pre.instantiate()

## 添加新的输入框元件
func _add_dialogue_input(): 
	var node:DialogueInput = dialogue_input_pre.instantiate()
	node.on_remove.connect(_refresh_window_height)
	dialogue_input_grid.add_child(node)

	node.enable_del()
	# node.call_deferred("test")
	return node

func _get_default_dialogue_input() -> DialogueInput:
	var node = dialogue_input_grid.get_node("DialogueInput")
	if node is DialogueInput:
		return node
	else: return null
	
## 因为DialogueInput的数量会变化，删除时会导致窗口位置不对，该函数来重置窗口
func _refresh_window_height() -> void:
	var count := dialogue_input_grid.get_children().size()
	var height := (count -1) * DIALOGUE_INPUT_HEIGHT
	self.size.y = height
	pass

func _on_role_picked():
	role_picker_window = EditorFileDialog.new()
	get_parent().add_child(role_picker_window)
	
	role_picker_window.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	role_picker_window.current_dir = "res://config/role_data"
	role_picker_window.add_filter("*.tres","角色配置")
	role_picker_window.file_selected.connect(_on_role_pick_complete)
	role_picker_window.popup_centered(Vector2i(800,600))
	pass
	
func _on_role_pick_complete(path):
	print("打开的文件路径是",path)
	if path == null or !path.begins_with("res://config/role_data/"):
		return
		#show_err("出现错误")
	if path: role_selected = load(path)
	_refresh_role_selected()


## 【连接信号】 当选择自动1时，才会显示等待时间
func _on_item_selected(index:int):
	if index == 1: wait_time_line.show()
	else : wait_time_line.hide()
	on_value_changed.emit()

func _refresh_role_selected():
	if role_selected:
		role_selected_text.text = role_selected.role_name
	else: role_selected_text.text = "无"
	

func set_value(role:Role,type:int,wait_time:int,_position_type = 2):
	# text_edit.text = text
	role_selected = role
	option_btn.selected = type
	spin_box.value =wait_time
	
	position_type.selected = _position_type
	_on_item_selected(type)
	_refresh_role_selected()
	# _refresh_preview()

## 刷新全部对话输入元件
func _refresh_dialogue_input(dialogue_list:Array[DialogueData]):
	var index = 0
	for data:DialogueData in dialogue_list:
		if index == 0: _get_default_dialogue_input().set_value(data)
		else: _add_dialogue_input().set_value(data)
		index += 1

## 获取对话数据列表
func _get_dialogue_list() -> Array[DialogueData]:
	var result:Array[DialogueData]
	var dialogue_input_list = dialogue_input_grid.get_children()
	for item in dialogue_input_list:
		if item is DialogueInput:
			result.append(item.to_data())
	return result

## 从数据
func from_data(data:BaseEventNode) -> BaseGN:
	if data is MessageNode: 
		role_selected = data.role
		option_btn.selected = data.type
		spin_box.value = data.wait_time
		position_type.selected = data.position_type
		_on_item_selected(data.type)
		_refresh_role_selected()
		_refresh_dialogue_input(data.dialogue_list)
	return self

## 转为数据
func to_data(_edit:GraphEdit) -> BaseEventNode:
	return MessageNode.new(BaseEventNode.MessageV2,self.position_offset,"",role_selected,option_btn.selected,spin_box.value,0,position_type.selected,_get_dialogue_list())
