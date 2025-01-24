@tool
extends Control
class_name PopMessage


@export var text:String:
	set(new):
		text = new
		## 当text变更时，更新对话框
		call_deferred("refresh")

@export var label:Label:
	get:return get_node("CenterContainer/MarginContainer/HBoxContainer/Label")

@export var container:PanelContainer

@export var arrow:TextureRect

func init():
	label.text = ""
	container.size = Vector2.ZERO
	
	pass

## 更新pop_message
func refresh():
	print("刷新pop_message")
	init()
	label.text = text
	#arrow.show()
	pass

#func _enter_tree() -> void:
	#arrow.hide()
	#pass

func _exit_tree() -> void:
	pass
