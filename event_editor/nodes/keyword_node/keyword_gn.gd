@tool
extends BaseGN
class_name KeywordGN

@export var keyword_line_edit:LineEdit:
	get:return get_node("HSplitContainer/TextEdit")

@export var text_preview:LineEdit:
	get:return get_node("HSplitContainer2/TextPreview")

func _enter_tree() -> void:
	keyword_line_edit.text_changed.connect(_refresh_preview)
	
func _exit_tree() -> void:
	keyword_line_edit.text_changed.disconnect(_refresh_preview)

func from_data(data:BaseEventNode) -> BaseGN:
	if data is KeywordData:
		keyword_line_edit.text = data.keyword
		_refresh_preview()
	return self

func _refresh_preview(val = null):
	text_preview.text = ""
	text_preview.text = TranslationServer.get_translation_object('zh_CN').get_message(keyword_line_edit.text)

func to_data(edit:GraphEdit) -> BaseEventNode:
	return KeywordData.new(BaseEventNode.Keyword,self.position_offset,keyword_line_edit.text)
