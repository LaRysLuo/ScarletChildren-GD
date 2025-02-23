@tool
extends VBoxContainer
class_name Tab

## 引用组件
var label:Label:
	get():return get_node("Label")
var cursor:Control:
	get():return get_node("TextureRect")

## 设置tab属性
func set_info(text:String):
	label.text = text
	unfocus()
	
func focus():
	cursor.show()
	pass

func unfocus():
	cursor.hide()
	pass

## 是否聚焦的
func is_focus():
	return cursor.visible
