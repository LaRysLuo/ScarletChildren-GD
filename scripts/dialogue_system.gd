extends Control
class_name DialogueSystem

#打字动画速度,数字越大，速度越快
@export var TYPING_SPEED = 150 

var dialogue_list:Array[DialogueInfo] = [] #要进行的对话文本
@onready var name_board: Control = $PanelContainer/MarginContainer/HBoxContainer/Control

@onready var name_label: Label = $PanelContainer/MarginContainer/HBoxContainer/Control/NameLabel
@onready var content_label: Label = $PanelContainer/MarginContainer/HBoxContainer/ContentLabel

var typing_tween:Tween
var typing_text:String
# 可以下一步
var nextable:bool:
	get(): return dialogue_list.size() >0 
var wait_input_mode:int = 0 #0表示没有 1表示打字中 2表示等待下一段输入 

# 信号
signal  dialogue_finish

func  _ready() -> void:
	self.hide()
	#start_dialogue([
		#DialogueInfo.new("resu","你好呀,我叫礼诗，你的名字是什么呢？"),
		#DialogueInfo.new("resu","接招吧！")
	#])

func show_message(text:String):
	var info :=  DialogueInfo.new("",text) # 生成对话信息
	#var temp_list :Array[DialogueInfo] = [ info]
	start_dialogue( [ info]) #开始对话

# 开始对话，传入对话文本
func start_dialogue(dialogue_list:Array[DialogueInfo]):
	if dialogue_list.is_empty(): 
		print_debug("传入的对话内容不能为空")
		return
	self.dialogue_list.append_array(dialogue_list)  #将文本加入待处理的对话
	print("当前的待显示的对话列表",self.dialogue_list)
	self.show()
	GameManager.set_game_state_buszing()
	if wait_input_mode == 0 : _next_dialogue() # 开始下一个对话
	


# 开始下一段对话	
func _next_dialogue():
	if dialogue_list.is_empty(): 
		self.hide()
		GameManager.set_game_state_normal()
		dialogue_finish.emit()
		return # 当对话文本是空的时候，结束对话模式
	var info = dialogue_list.pop_front() #取出第一个对话内容
	if info: _render_content(info) # 渲染对话框内容

# 渲染对话框
func _render_content(info:DialogueInfo):
	if info.character_name == "":
		print("没有名字隐藏名字板")
		name_board.hide()
	else:
		name_board.show()
		name_label.text = info.character_name
	typing_tween = get_tree().create_tween()
	content_label.text = ""
	typing_text = info.dialogue_text
	var time:float =   10.0 / TYPING_SPEED  # 10 / 100 = 0.1
	for char in typing_text:
		typing_tween.tween_callback(_append_character.bind(char)).set_delay(time)
	typing_tween.connect("finished",func():wait_input_mode = 2)
	wait_input_mode = 1

# 渲染打字机效果
func _append_character(character:String):
	content_label.text += character
	
# 跳过打印机动画
func _skip_typing_anim():
	content_label.text = typing_text
	typing_tween.stop()
	wait_input_mode = 2
	
# 等待玩家点击Z键，继续下一行
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("submit"):
		match wait_input_mode:
			1: _skip_typing_anim() #如果正在打字中，跳过打字直接出现文字
			2: _next_dialogue() #如果等待输入中，则进入下一段对话
	pass
