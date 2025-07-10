extends InputableScene
class_name MenuV2

""" 
# 使用说明 #
该组件MenuV2需要配合LbuttonV2使用
在使用该函数前，请先配置好MenuV2下btn_trans变量路径下的LbuttonV2

然后选设置 set_handler,设置按键标识和其回调函数

使用activate函数显示窗口
使用deactivate函数隐藏窗口

"""

@export var selected_btn_color:Color

# var handlers:Dictionary

var btn_trans:Control:
	get: return get_node("MarginContainer/VBoxContainer")

var btns:Array[LbuttonV2]:
	get:
		var list:Array[LbuttonV2] = [] 
		for btn:LbuttonV2 in btn_trans.get_children():
			if !btn.visible: continue
			list.append(btn)
		return list

var active_btns:Array[LbuttonV2]:
	get: return btns.filter(func(item:LbuttonV2):return !item.disable)

## 当前选中的
var selected:int = -1

## 之前选中的
var last_selected:int = -1


## 信号
signal on_select_sfx # 给cursor移动发出声音预留的信号



## 激活窗口
func activate(): 
	super.activate()
	# active = true
	if selected == -1:_select(0,true)
	show()
	
## 冻结窗口
func deactivate(with_hide:bool = true): 
	super.deactivate()
	if with_hide:hide()



## 通过symbol找出对应按钮
func get_btn(symbol:String) -> LbuttonV2:
	return btns.filter(func(item:LbuttonV2):return item.symbol == symbol).front()


## 初始化
func _ready() -> void:
	_init_handlers()
	_init_btn_selected_color()
	deactivate()

func _init_btn_selected_color() ->void:
	for btn:LbuttonV2 in btns:
		btn.selected_color = selected_btn_color

func _init_handlers() -> void:
	set_handler("ok",_confirm_handle)
	set_handler("cursor_move",_cursor_move_handler)

func _cursor_move_handler(key:int):
	match key:
		UP:_prev_handle()
		DOWN:_next_handle()

## 向上移动
func _prev_handle():
	_select(selected - 1)
	pass

## 向下移动
func _next_handle():
	_select(selected + 1)
	pass

## 确认
func _confirm_handle():
	var btn:LbuttonV2 = active_btns[selected]
	var symbol:String = btn.symbol
	if _handlers.has(symbol): _handlers.get(symbol).call()


## 选择
func _select(val:int,ingore_sfx:bool = false):
	if val < 0 || val >= active_btns.size():
		print_rich("[COLOR=YELLOW]移动到边界[/COLOR]")
		return 
	print("开始移动光标")
	last_selected = selected
	selected = val
	var btn:LbuttonV2 = active_btns[selected]
	btn.focus()
	var last:LbuttonV2 = active_btns[last_selected]
	last.unfocus()
	if not ingore_sfx:on_select_sfx.emit()
