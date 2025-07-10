@tool
extends InputableScene
class_name ItemInner

## 组件引用

@onready var icon_tr:TextureRect = $HBoxContainer/Icon
@onready var label_tr: Label = $HBoxContainer/Label

## 文本
@export var label:String

## 图标
@export var icon:Texture2D


var _focus:bool =  false

## SIGNAL
signal lb_select_changed(index: int) # 选择变化
signal lb_submit # 提交
signal on_inited #初始化完成
signal lb_cancel # 取消

func set_info(_label:String,_icon:Texture2D):
	self.label = _label
	self.icon = _icon
	_refresh()
	on_inited.emit()

func _ready() -> void:
	_init_handers()
	pass

func _init_handers():
	set_handler("ok",func(): lb_submit.emit())
	set_handler("cancel",func(): lb_cancel.emit())
	set_handler("cursor_move",func(key:int):lb_select_changed.emit(key))


## 重写基类的函数
func _handler_action_input(key:int):
	if !_focus: return # 按按钮没被选中是，跳过
	super._handler_action_input(key)


## 回调函数
# func _input(event: InputEvent) -> void:
# 	if _focus == false || !is_visible_in_tree(): return 
# 	if event.is_action_pressed("up"): #3
# 		get_window().set_input_as_handled()
# 		lb_select_changed.emit(3)
# 	if event.is_action_pressed("down"):#0
# 		print("输入2")
# 		get_window().set_input_as_handled()
# 		lb_select_changed.emit(0)
# 	if event.is_action_pressed("left"):#1
# 		get_window().set_input_as_handled()
# 		lb_select_changed.emit(1)
# 	if event.is_action_pressed("right"):#2
# 		get_window().set_input_as_handled()
# 		lb_select_changed.emit(2)
# 	if event.is_action_pressed("submit"):
# 		print("按钮触发了提交事件")
# 		get_window().set_input_as_handled()
# 		lb_submit.emit()
# 	if event.is_action_pressed("cancel"):
# 		print("按钮触发了取消事件")
# 		get_window().set_input_as_handled()
# 		lb_cancel.emit()

func _refresh():
	icon_tr.texture = icon
	label_tr.text = label
	unfocus()


## 聚焦
func focus(): 
	_focus = true
	self.self_modulate = Color(1, 1, 1, 0.5)


## 取消聚焦
func unfocus():
	_focus = false
	self.self_modulate = Color(1, 1, 1, 0)
