extends CanvasLayer
class_name DialogueSystem

## ==================== 
# 这是一个对话框管理组件
## ====================

## 对话框状态
const None = 0
const Typing = 1
const WaitInput = 2
const AutoPlay = 3

## 对外显示的配置属性 
 #打字动画速度,数字越大，速度越快
@export var TYPING_SPEED = 120 

## 组件引用
@onready var tachie_tr:TextureRect = get_node("TextureRect")
@onready var dialogue_box:Control = get_node("DialogueBox")
@onready var key_tips:KeyTipsBottom = get_node("DialogueBox/MarginContainer2/KeyTipsBottom")
@onready var name_board: Control = get_node("DialogueBox/MarginContainer/VBoxContainer/Control")
@onready var name_label: Label = get_node("DialogueBox/MarginContainer/VBoxContainer/Control/NameLabel")
@onready var content_label: RichTextLabel = get_node("DialogueBox/MarginContainer/VBoxContainer/ContentLabel")
@onready var options_node:OptionMenu =  get_node("Options") as OptionMenu # Options组件的基节点
@onready var nextable_sign_tr:Control = get_node("DialogueBox/MarginContainer/VBoxContainer/Control2") 

var typing_tween:Tween
var typing_text:String

## 本地属性

## 对话框
var dialogue_list:Array[DialogueInfo] = [] #要进行的对话文本
var wait_input_mode:int = None #0表示没有 1表示打字中 2表示等待下一段输入 

## 选项框
var is_option_show:bool = false

## 思考模式
var key_index = 0 # 关键词索引
var dialogue_options_list = [] # 这是用联想关键词使用的数组
var ponder_mode:bool = false  # 思考模式
var color_code_start = "[color=#FFB92D]" # 关键词颜色代码开始
var color_code_end = "[/color]" # 关键词颜色结束
var dialogue_link_list = [] # 道具联想列表

## 计算只读属性
var nextable:bool: # 可以下一步
	get(): return self.dialogue_list.size() >0 

## 信号
signal dialogue_typing_finish # 对话打字结束
signal dialogue_finish # 对话显示结束
signal options_finish(index:int) # 选项模式结束
signal on_typing # 正在打字时，可用于增加音效


#region 生命周期

func _enter_tree() -> void:
	InputManager.on_action_pressed.connect(_action_input)
	
func _exit_tree() -> void:
	InputManager.on_action_pressed.disconnect(_action_input)

func  _ready() -> void:
	## 把对话框体和选项框体隐藏
	_hide_msgbox()
	_hide_option_window()
	_translate_all_labels(self)
	_hide_ponder_tips()

#endregion

#region 信号函数

func _action_input(key:int):
	if wait_input_mode == 3 ||  wait_input_mode == 0: return
	## 按下A时
	if key == InputManager.KEY_A  && !ponder_mode:
		match wait_input_mode:
			Typing: 	_skip_typing_anim() #如果正在打字中，跳过打字直接出现文字
			WaitInput:  _next_dialogue() #如果等待输入中，则进入下一段对话

	if wait_input_mode == Typing: return
	## 按下A，思考关键词
	if key == InputManager.KEY_A && ponder_mode:
		get_window().set_input_as_handled()
		_submit_ponder()
		return
	## 按下B时
	if key == InputManager.KEY_B && ponder_mode:
		get_window().set_input_as_handled()
		_end_ponder_mode()
		pass
	## 按下Y时
	# 弹出物品选择框
	if  key == InputManager.KEY_Y && ponder_mode:
		get_window().set_input_as_handled()
		_show_item_picker()
		pass
	
	## 按下Y时进行联想
	if key == InputManager.KEY_Y && !dialogue_options_list.is_empty() && !ponder_mode:
		get_window().set_input_as_handled()
		_start_ponder_mode()
	if !ponder_mode:return
	if key == InputManager.KEY_LEFT && key_index > 0:
		get_window().set_input_as_handled()
		key_index -= 1
		_update_ponder_highlight() 
		pass
	if key == InputManager.KEY_RIGHT && key_index < dialogue_options_list.size() - 1:
		get_window().set_input_as_handled()
		key_index += 1
		_update_ponder_highlight()

#endregion

#region 对外函数

## 【对外】显示消息
func show_message(text:String,wait_type:int,wait_time:float,role:Role = null):
	print("text=",text)
	var info :=  DialogueInfo.new(role,text,wait_type,wait_time) # 生成对话信息
	#var temp_list :Array[DialogueInfo] = [ info]
	_start_dialogue( [ info]) #开始对话

## 【对外】显示选项
## 参数
## name
## child_index
## 使用await DialogueManager.options_finish来获取选择的child_index
func show_options(options:Array[Dictionary]):
	is_option_show = true
	var index = 0
	for opt in options:
		var name = opt["name"]
		#var child_index = opt["child_index"]
		options_node.add_option(name,_options_confirm.bind(index))
		index +=1
	dialogue_box.show()
	options_node.enable()
	options_node.show()

## 设置关键词
func set_keyword(keyword_list):
	self.dialogue_options_list = keyword_list
	
## 设置联想道具
func set_item_link(link_list):
	self.dialogue_link_list = link_list

#endregion


#region 内部函数
## 递归翻译按钮
func _translate_all_labels(node):
	for child in node.get_children(true):
		if child is Label:
			print("翻译按钮=",tr(child.text))
			child.text = tr(child.text)
		_translate_all_labels(child)

## 开始对话，传入对话文本
func _start_dialogue(dialogue_list:Array[DialogueInfo]):
	if dialogue_list.is_empty(): 
		push_error("传入的对话内容不能为空")
		return
	self.dialogue_list.append_array(dialogue_list)  #将文本加入待处理的对话
	print("当前的待显示的对话列表",self.dialogue_list.size())
	dialogue_box.show()
	if wait_input_mode == None : _next_dialogue() # 开始下一个对话

## 渲染对话框
func _render_content(info:DialogueInfo):
	if !info.role: 
		name_label.hide()
		tachie_tr.hide()
	else:
		## 如果角色名字有数据，显示名字板
		if info.role.role_name != "": 
			name_label.label_settings.font_color = info.role.theme_color
			name_label.text = info.role.role_name
			name_label.show()

		## 如果角色有立绘，则显示立绘
		if info.role.tachie:
			tachie_tr.show()
			tachie_tr.texture = info.role.tachie
	
	typing_tween = get_tree().create_tween()
	content_label.text = ""
	#print("开始打字=",content_label.text)
	typing_text = tr(info.dialogue_text) 
	var time:float =   10.0 / TYPING_SPEED  # 10 / 100 = 0.1
	
	for char in typing_text:
		typing_tween.tween_callback(_append_character.bind(char)).set_delay(time)
	
	typing_tween.connect("finished",func():
		#print("打字完成")
		if info.wait_type == 0:
			_start_wait_input()
		else:
			var wait_time:float = info.wait_time / 1000.0
			#print("wait_time",info.wait_time)
			var auto_next_timer:SceneTreeTimer = get_tree().create_timer(wait_time)
			auto_next_timer.timeout.connect(_next_dialogue)
	)
	await  get_tree().create_timer(0.1).timeout
	if info.wait_type == 0: wait_input_mode = Typing
	else: wait_input_mode = AutoPlay

## 渲染打字机效果
func _append_character(character:String):
	content_label.text += character
	on_typing.emit()

## 开始下一段对话	
func _next_dialogue():
	_hide_ponder_tip()
	if self.dialogue_list.is_empty() : 
		wait_input_mode = None
		## 等待100ms才关闭对话框
		await get_tree().create_timer(0.1).timeout
		_hide_msgbox()
		#GameManager.set_game_state_normal()
		dialogue_finish.emit(-1)
		return # 当对话文本是空的时候，结束对话模式
	var info = self.dialogue_list.pop_front() #取出第一个对话内容
	if info: _render_content(info) # 渲染对话框内容

# 跳过打印机动画
func _skip_typing_anim():
	content_label.text = typing_text
	typing_tween.stop()
	_start_wait_input()
	
## 表示现在等待输入
func _start_wait_input():
	wait_input_mode = WaitInput
	nextable_sign_tr.show()
	dialogue_typing_finish.emit()
	
	_show_ponder_tip()

## 隐藏对话框
func _hide_msgbox():
	tachie_tr.hide()
	dialogue_box.hide()
	nextable_sign_tr.hide()
	ponder_mode = false

## 隐藏思考模式的按键提示
func _hide_ponder_tips():
	key_tips.hide()

## 确认选择
func _options_confirm(index:int):
	print("输出结果:",index)
	## 关闭选项
	options_node.disable()
	options_node.hide()
	_hide_msgbox()
	#GameManager.set_game_state_normal()
	is_option_show = false
	## INFO 初始化wait_input_mode是为了让对话框恢复正常
	wait_input_mode = None
	options_finish.emit(index)

## 隐藏选项框
func _hide_option_window():
	options_node.hide()

## 是否可以显示思考模式
func _can_ponder_mode() -> bool:
	if dialogue_options_list.is_empty():return false
	return true

## 显示思考提示
func _show_ponder_tip():
	if _can_ponder_mode():
		key_tips.set_btns_info({
			"arrow_btn": KeyTipsConfig.new("",false),
			"a_btn": KeyTipsConfig.new("",false),
			"b_btn": KeyTipsConfig.new("",false),
			"x_btn": KeyTipsConfig.new("思考"),
			"y_btn": KeyTipsConfig.new("",false),
		})
		key_tips.show()
		#start_ponder_mode_hb.show()

## 隐藏思考提示
func _hide_ponder_tip():
	key_tips.hide()

## 开始思考模式
func _start_ponder_mode():
	ponder_mode = true
	self.key_index = 0
	key_tips.set_btns_info({
		"a_btn": KeyTipsConfig.new("思考"),
		"b_btn": KeyTipsConfig.new("返回"),
		"x_btn": KeyTipsConfig.new("",false),
		"y_btn": KeyTipsConfig.new("联想"),
	})
	_update_ponder_highlight()

## 确认思考模式
func _submit_ponder():
	print("思考提交")
	_end_ponder_mode()
	wait_input_mode = None
	_hide_msgbox()
	#GameManager.set_game_state_normal()
	dialogue_finish.emit({
		"type":1,
		"key_index":key_index
	})

## 结束思考模式
func _end_ponder_mode():
	_show_ponder_tip()
	#self.dialogue_options_list.clear()
	#key_index = 0
	#ponder_mode_hb.hide()
	ponder_mode = false
	_clear_ponder_highlight()

## 道具是否能连接
func _can_link() -> bool:
	var ky:KeywordData = dialogue_options_list[key_index]
	return	ky.get_item_link() != null || ky.get_none_matched() != null

## 显示物品选择栏
func _show_item_picker():
	if !_can_link():
		AudioManager.play_buzzle() 
		return
	self.hide()
	var item_picker:NeoItemList = await SceneManager.navigate_to("scene_item_list")
	item_picker.start_picker_mode(_picker_confirm,func():self.show())
	pass

## 选择确定
func _picker_confirm(item:Item):
	print("选择器结果=",item)
	self.show()
	# 判断是否有匹配的item
	var matched = _match_link(item)
	_end_ponder_mode()
	wait_input_mode = None
	_hide_msgbox()
	dialogue_finish.emit({
		"type":2,
		"key_index":key_index,
		"matched": matched
	})

## 匹配联想
func _match_link(item:Item) -> bool:
	var keyword:KeywordData = dialogue_options_list[key_index]
	var filter_link:ItemlinkData = keyword.get_item_link()
	#print("filter_link1=",filter_link.item_id)
	#print("filter_link2=",item.item_id)
	if filter_link:
		return filter_link.item_id ==  item.item_id
		
	#var filters = list.filter(func(link:ItemlinkData): return item.item_id == link.item_id)
	#if !filters.is_empty(): return filters[0]
	## 没有匹配到
	return false

## 更新关键词高亮
func _update_ponder_highlight():
	_clear_ponder_highlight()
	content_label.text = apply_bbcode(content_label.text)
	
	if _can_link(): key_tips.enable_key(KeyTipsBottom.keyType.key_y)
	else: key_tips.disable_key(KeyTipsBottom.keyType.key_y)
	
## 清除关键词高亮
func _clear_ponder_highlight():
	content_label.text = _clear_bbcode(content_label.text)

## 函数：匹配关键词并添加 BBCode
func apply_bbcode(text):
	var result_text = text
	var keyword = tr(dialogue_options_list[key_index].keyword)
	if !keyword:
		push_error("出错了，好像配置了一个无法匹配的keyword！")
		return
	# 用 BBCode 包裹匹配的关键词
	result_text = result_text.replace(
		keyword, 
		"{}{}{}".format([color_code_start,keyword,color_code_end],'{}')
		)
	return result_text

## 清除bbcode
func _clear_bbcode(text):
	var result_text = text
	result_text = result_text.replace(color_code_start,'')
	result_text = result_text.replace(color_code_end,'')
	return result_text

#endregion

var input_triggered := false

# 等待玩家点击Z键，继续下一行
func _input(event: InputEvent) -> void:
	if event.is_released():
		self.input_triggered = false
	
	
	
