## 消息节点的VIEW
@tool
extends BaseGN
class_name MessageGN

@export var wait_type_btn:OptionButton 
@export var wait_time_line:Control

var role_picker_window

var role_selected:Role

## 角色选择器
var role_picker_btn:Button:
	get: return get_node("VBoxContainer/Line1/HSplitContainer/Button")

## 选择的角色名
var role_selected_text:Label:
	get:return get_node("VBoxContainer/Line1/HSplitContainer/Label")

## 文本输入框
var text_edit:LineEdit:
	get: return get_node("VBoxContainer/HSplitContainer3/LineEdit")

## 文本预览框
var text_preview:RichTextLabel:
	get:return get_node("VBoxContainer/TextPreview")


## 选项选择框
var option_btn:OptionButton:
	get: return get_node("VBoxContainer/HSplitContainer/OptionButton")

## 数字输入框
var spin_box:SpinBox:
	get: return get_node("VBoxContainer/HSplitContainer2/SpinBox")

## 表情
var expression_opt:OptionButton:
	get: return get_node("VBoxContainer/HSplitContainer4/OptionButton")


func _enter_tree() -> void:
	wait_type_btn = $VBoxContainer/HSplitContainer/OptionButton
	wait_time_line = $VBoxContainer/HSplitContainer2
	wait_time_line.hide()
	
	## 输入按钮的初始化
	wait_type_btn.item_selected.connect(_on_item_selected)
	text_edit.text_changed.connect(on_changed)
	spin_box.changed.connect(on_changed)
	
	role_picker_btn.pressed.connect(_on_role_picked)
	
	

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
	

func  set_value(text:String,role:Role,type:int,wait_time:int,expression_id = 0):
	text_edit.text = text
	role_selected = role
	option_btn.selected = type
	spin_box.value =wait_time
	expression_opt.selected = expression_id if expression_id else 0
	_on_item_selected(type)
	_refresh_role_selected()
	_refresh_preview()

## 当数据有变更时
func on_changed(_val):
	on_value_changed.emit()
	_refresh_preview()

func _refresh_preview():
	print("1111:",TranslationServer.get_translation_object('zh_CN').get_message_list()[221])
	text_preview.text = TranslationServer.get_translation_object('zh_CN').get_message(text_edit.text)

func to_data(_edit:GraphEdit) -> BaseEventNode:
	return MessageNode.new(BaseEventNode.Message,self.position_offset,text_edit.text,role_selected,option_btn.selected,spin_box.value,expression_opt.selected)
