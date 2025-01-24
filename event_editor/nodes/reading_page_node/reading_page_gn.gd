@tool
extends BaseGN
class_name ReadingPageGN

## 组件引用
# 标题Label
var content_label:LineEdit:
	get(): return get_node("VBoxContainer/HSplitContainer3/TextEdit")

# 文本预览
var text_preview:TextEdit:
	get():return get_node("VBoxContainer/HSplitContainer5/TextEdit")

func _enter_tree() -> void:
	content_label.text_changed.connect(on_changed)

func _exit_tree() -> void:
	content_label.text_changed.disconnect(on_changed)
	
## 当数据有变更时
func on_changed(val):
	on_value_changed.emit()
	_refresh_preview()

## 刷新预览
func _refresh_preview():
	text_preview.text = TranslationServer.get_translation_object('zh_CN').get_message(content_label.text)
	
func from_data(data:BaseEventNode) -> BaseGN:
	if data is ReadingPageData:
		content_label.text = data.content
		_refresh_preview()
	return self

func to_data(edit:GraphEdit) -> BaseEventNode:
	return ReadingPageData.new(BaseEventNode.ReadingPage,self.position_offset,content_label.text)
