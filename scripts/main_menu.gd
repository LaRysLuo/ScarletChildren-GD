extends CanvasLayer

var itemList:Array[LButton]
@onready var menuPanel = $MenuPanel

var last := -1
var index := 0

## 按键handler
var btn_handler = {
	"item": _to_item,
	"lib": _to_lib,
	"load":null
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#visibility_changed.connect(func ():
		#get_tree().paused = visible)
	var list = menuPanel.get_children()
	for item in list:
		if item is LButton: 
			itemList.append(item)
			if item.symbol && btn_handler.get(item.symbol):
				item.lb_submit.connect(btn_handler.get(item.symbol))
			item.connect("lb_select_changed",on_select)
	init_window()
	pass # Replace with function body.

func init_window():
	AudioManager.play_se("Computer")
	select(0,true)


var input_triggered := false

# 检测输入
func _input(event: InputEvent) -> void:
	if !visible:return
	## 按下取消
	if event.is_action_pressed("cancel") && !input_triggered:
		self.input_triggered = true
		get_window().set_input_as_handled()
		close_window()
	
	if event.is_released():
		self.input_triggered = false
		
func close_window():
	SceneManager.backto()
	

func on_item_menu():
	SceneManager.navigate_to("scene_item_list")
	pass

func on_other():
	pass	

func select(_index:int,skip_se:bool = false):
	index = _index
	var last_btn = itemList[last]
	var btn = itemList[index]
	if last_btn: last_btn.unfocus()
	if btn: btn.focus(skip_se)
	if last != index: last = index

func _on_tree_entered() -> void:
	var timer =  get_tree().create_timer(0.1)
	timer.connect("timeout",func():
		print("计时器触发")
	)
	pass # Replace with function body.

func on_select(event:int):
	print("list的数量：",itemList.size())
	match  event:
		3:
			# 向下移动
			if index > 0: select(index-1)
		0:
			# 向上移动
			if index < itemList.size() -1: select(index+1)

## 跳转到道具列表
func _to_item():
	SceneManager.navigate_to("scene_item_list")
	
## 跳转到资料列表
func _to_lib():
	SceneManager.navigate_to("scene_lib")
