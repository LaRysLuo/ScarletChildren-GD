## 这是所有自定义节点VIEW的基类
@tool
extends GraphNode
class_name BaseGN

@export var ori_id = null

## 这里是信号
# 当值改变时发出信号
signal  on_value_changed

func show_err(msg:String):
	var dialogue= AcceptDialog.new()
	dialogue.dialog_text = msg
	get_parent().add_child(dialogue)
	dialogue.popup_centered()

## WARNING 继承该类需要重写
func from_data(data:BaseEventNode) -> BaseGN:
	printerr("未重写from_data")
	return null

## WARNING 继承该类需要重写 
## 将保存的数据转为储存数据
func to_data(edit:GraphEdit) -> BaseEventNode:
	printerr("未重写to_data")
	return null
