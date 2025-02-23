extends CanvasLayer

var itemList:Array[LButton]
@onready var menuPanel = $MenuPanel
@onready var audio_player:AudioPlayer = $AudioPlayer
@onready var scene_name_label: SceneNameLabel = $SceneNameLabel
@onready var game_timer: GameTimer = $GameTimer
@onready var input_dispat : InputDispatcher = $InputDispatcher

var last := -1
var index := 0

var finished = false

## 按键handler
var btn_handler = {
	"item": _to_item,
	"lib": _to_lib,
	"load":null
}

func _ready() -> void:
	var list = menuPanel.get_children()
	for item in list:
		if item is LButton: 
			itemList.append(item)
			if item.symbol && btn_handler.get(item.symbol):
				item.lb_submit.connect(btn_handler.get(item.symbol))
			item.connect("lb_select_changed",on_select)
	init_window()

func init_window():
	audio_player.manager.play_se("Computer")
	input_dispat.on_ui_pressed.connect(_ui_input)
	select(0,true)


# 检测输入
func _ui_input(input_key:int) -> void:
	if !visible || finished:return
	## 按下取消
	if input_key == input_dispat.KEY_B:
		get_window().set_input_as_handled()
		close_window()
		
func close_window():
	finished = true
	GameManager.scene_manager.backto()
	pass
	

func on_item_menu():
	# SceneManager.navigate_to("scene_item_list")
	pass

func on_other():
	pass	

func select(_index:int,skip_se:bool = false):
	index = _index
	var last_btn = itemList[last]
	var btn = itemList[index]
	if last_btn: last_btn.unfocus()
	if btn: btn.focus()
	if !skip_se:
		audio_player.manager.play_se("Cursor")
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
	# SceneManager.navigate_to("scene_item_list")
	pass
	
## 跳转到资料列表
func _to_lib():
	# SceneManager.navigate_to("scene_lib")
	pass
