@tool
extends Control
class_name PopDialogue

@onready var panel_container: PanelContainer = $PanelContainer
@onready var contentLabel: Label = $PanelContainer/MarginContainer/Content

const MAX_WIDTH:int = 400

var list:Array[String] = [
	"你好呀,我的朋友啊",
	"在干嘛呀"
]

var index:int = 0


func _ready() -> void:
	show_dialogue()

@export_multiline var content : String:
	set(new):
		content = new
		print("11111")
		if Engine.is_editor_hint():
			print("11111")
			relayout()

# 显示对话内容
func show_dialogue():
	#把对话框显示出来
	panel_container.show()
	#把文字放入content
	var item = list[index]
	contentLabel.text = item
	#根据文字长度调节大小
	var width = item.length() * 18
	panel_container.size = Vector2(width,39)
	print("当前文字的长度为：",item.length()) 


func relayout():
	print("文字内容改变，重新刷新")
