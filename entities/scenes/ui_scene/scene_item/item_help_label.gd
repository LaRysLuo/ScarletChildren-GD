extends HBoxContainer
class_name ItemHelpLabel

## 组件引用
var label:Label:
	get():return get_node("Label")
	
func _ready() -> void:
	label.text = ""
	
func set_info(text:String):
	label.text = text
	
