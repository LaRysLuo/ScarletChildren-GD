@tool
extends VBoxContainer
class_name DialogueInput

## 文本输入框
var text_edit:LineEdit:
    get: return get_node("HSplitContainer3/HBoxContainer/LineEdit")

## 文本预览框
var text_preview:RichTextLabel:
    get:return get_node("TextPreview/TextEdit")

## 表情
var expression_opt:OptionButton:
    get: return get_node("HSplitContainer4/OptionButton")

var del_btn:Button:
    get: return get_node("HSplitContainer3/HBoxContainer/Button")

func _enter_tree() -> void:
    del_btn.pressed.connect(_delete_dialogue_input)
    text_edit.text_changed.connect(on_changed)
    
signal on_remove

## 当数据有变更时
func on_changed(_val):
    # on_value_changed.emit()
    _refresh_preview()

func _refresh_preview():
    # print("1111:",TranslationServer.get_translation_object('zh_CN').get_message_list()[221])
    text_preview.text = TranslationServer.get_translation_object('zh_CN').get_message(text_edit.text)

## 禁用删除按钮
func enable_del():
    del_btn.disabled = false



## 删除本对话组
func _delete_dialogue_input():
    get_parent().remove_child(self)
    on_remove.emit()
    queue_free()

## 设置参数
func set_value(dialogue_input:DialogueData):
    print("text_edit:",text_edit)
    text_edit.text = dialogue_input.text_id
    expression_opt.selected = dialogue_input.expression_id if dialogue_input.expression_id else 0
    _refresh_preview()

## 获取数据
func to_data() -> DialogueData:
    return DialogueData.new(text_edit.text,expression_opt.selected)