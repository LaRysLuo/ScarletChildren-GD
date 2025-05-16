extends Panel
class_name MenuV2

""" 
# 使用说明 #
该组件MenuV2需要配合LbuttonV2使用
在使用该函数前，请先配置好MenuV2下btn_trans变量路径下的LbuttonV2

然后选设置 set_handler,设置按键标识和其回调函数

使用activate函数显示窗口
使用deactivate函数隐藏窗口

"""


var handlers:Dictionary

var btn_trans:Control:
	get: return get_node("MarginContainer/VBoxContainer")

var btns:Array[LbuttonV2]:
	get:
		var list:Array[LbuttonV2] = [] 
		for btn:LbuttonV2 in btn_trans.get_children():
			list.append(btn)
		return list

## 当前选中的
var selected:int = -1

## 之前选中的
var last_selected:int = -1

## 激活的
var active:bool = false



## 设置Handler
func set_handler(symbol:String,callable:Callable):
	handlers[symbol] = callable

## 激活窗口
func activate(): 
	active = true
	_select(0)
	show()
    
## 冻结窗口
func deactivate(): 
	active = false
	hide()

## 初始化
func _ready() -> void:
	InputManager.on_action_pressed.connect(_action_input)
	deactivate()



## 输入
func _action_input(key:int):
	match key:
		InputManager.KEY_A: _confirm_handle()
		InputManager.KEY_B: _cancel_handle()
		InputManager.KEY_UP: _prev_handle()
		InputManager.KEY_DOWN: _next_handle()

## 向上移动
func _prev_handle():
	if !active: return
	_select(selected - 1)
	pass

## 向下移动
func _next_handle():
	if !active: return
	_select(selected + 1)
	pass

## 确认
func _confirm_handle():
	var btn:LbuttonV2 = btns[selected]
	var symbol:String = btn.symbol
	if handlers.has(symbol): handlers.get(symbol).call()

## 回退
func _cancel_handle():
	if handlers.has("cancel"): handlers.get("cancel").call()

## 选择
func _select(val:int):
	if val < 0 || val >= btns.size():
		print_rich("[COLOR=YELLOW]移动到边界[/COLOR]")
		return 
	print("开始移动光标")
	last_selected = selected
	selected = val
	var btn:LbuttonV2 = btns[selected]
	btn.focus()
	var last:LbuttonV2 = btns[last_selected]
	last.unfocus()


