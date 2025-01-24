@tool
extends VBoxContainer
class_name OptionItem

const ADD = 1
const DEL = 2

signal on_delte
signal on_add



var addBtn:Button:
	get(): return get_node("HSplitContainer/HBoxContainer/addBtn")

var delBtn:Button:
	get(): return get_node("HSplitContainer/HBoxContainer/delBtn")
	
var label:Label:
	get():return get_node("HSplitContainer/Label")
	
var text:LineEdit:
	get():return get_node("HBoxContainer/TextEdit")
	
var text_preview:LineEdit:
	get():return get_node("HBoxContainer2/TextEdit")

## 为按钮添加信号
func _enter_tree() -> void:
	addBtn.button_down.connect(func():on_add.emit())
	delBtn.button_down.connect(func():on_delte.emit(self))
	text.text_changed.connect(_refresh_preview)
	

## 为按钮清除信号
func _exit_tree() -> void:
	addBtn.button_down.disconnect(func():on_add.emit())
	delBtn.button_down.disconnect(func():on_delte.emit(self))
	text.text_changed.disconnect(_refresh_preview)
	
## 设置选项的可视性
func set_option_visible(type:int,state:bool):
	match type:
		ADD:
			if state == true: addBtn.show()
			else: addBtn.hide()
		DEL:
			if state == true: delBtn.show()
			else: delBtn.hide()

func set_text(val:String,index:int):
	self.label.text = "选项 " + str(index+1)
	self.text.text = val
	_refresh_preview()
	
## 刷新文字预览
func _refresh_preview(val = null):
	text_preview.text = ""
	text_preview.text = TranslationServer.get_translation_object('zh_CN').get_message(text.text)
