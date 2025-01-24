@tool
extends BaseGN
class_name ReadingModeGN


## 组件引用
# 标题Label
var title_label:LineEdit:
	get(): return get_node("VBoxContainer/HSplitContainer3/LineEdit")

# 文本预览
var text_preview:LineEdit:
	get():return get_node("VBoxContainer/HSplitContainer5/LineEdit")

# 关闭方式：是否随时关闭
var check_box:CheckBox:
	get(): return get_node("VBoxContainer/HSplitContainer4/CheckBox")


func _enter_tree() -> void:
	title_label.text_changed.connect(on_changed)

func _exit_tree() -> void:
	title_label.text_changed.disconnect(on_changed)

## 当数据有变更时
func on_changed(val):
	on_value_changed.emit()
	_refresh_preview()

## 刷新预览
func _refresh_preview():
	text_preview.text = TranslationServer.get_translation_object('zh_CN').get_message(title_label.text)


func from_data(data:BaseEventNode) -> BaseGN:
	if data is ReadingData:
		title_label.text = data.title
		check_box.button_pressed = data.close_any_time
		_refresh_preview()
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	return ReadingData.new(BaseEventNode.Reading,self.position_offset,title_label.text,check_box.button_pressed)
	
