extends CanvasLayer
class_name MainMenu

@onready var menuPanel = $MenuPanel
@onready var menu_v2:MenuV2 = $MenuV2
@onready var bg_panel:Panel = $Panel
@onready var panel_bg:TextureRect = $PanelBg
@onready var window_item:WindowItem = $WindowItem

@export var mapshot:Texture2D

## 初始化
func _ready() -> void:
	_init_window_item()
	_init_menu_v2()

## 初始化道具列表窗口
func _init_window_item():
	window_item.set_items([{
		"name":"测试道具",
		"key": "01",
		"desc":"测试测试测试1",
		"icon":null
	},
	{
		"name":"测试道具2",
		"key": "01",
		"desc":"测试测试测试2",
		"icon":null
	},
	{
		"name":"测试道具3",
		"key": "01",
		"desc":"测试测试测试3",
		"icon":null
	},{
		"name":"测试道具4",
		"key": "01",
		"desc":"测试测试测试3",
		"icon":null
	},{
		"name":"测试道具5",
		"key": "01",
		"desc":"测试测试测试4",
		"icon":null
	},
	{
		"name":"测试道具6",
		"key": "01",
		"desc":"测试测试测试5",
		"icon":null
	},
	{
		"name":"测试道具7",
		"key": "01",
		"desc":"测试测试测试6",
		"icon":null
	},
		{
		"name":"测试道具8",
		"key": "01",
		"desc":"测试测试测试7",
		"icon":null
	},
		{
		"name":"测试道具9",
		"key": "01",
		"desc":"测试测试测试8",
		"icon":null
	},
		{
		"name":"测试道具10",
		"key": "01",
		"desc":"测试测试测试9",
		"icon":null
	},
		{
		"name":"测试道具11",
		"key": "01",
		"desc":"测试测试测试10",
		"icon":null
	}
	])

	window_item.on_select_changed.connect(func(): AudioManager.play_cursor_move())
	window_item.on_submit.connect(func():AudioManager.play_puzzle_complete())
	window_item.on_cancel.connect(_item_back)

## 初始化menuV2窗口
func _init_menu_v2():
	menu_v2.set_handler("item",_to_item)
	menu_v2.set_handler("cancel",close_window)
	AudioManager.play_se("Computer")
	menu_v2.activate()

## 设置屏幕图片
func set_mapshot(_mapshot:Texture2D):
	panel_bg.texture =  _mapshot as Texture2D
	print_debug("texture:",_mapshot as Texture2D)
	self.mapshot = _mapshot

## 关闭该窗口
func close_window():
	SceneManager.backto()
	
# func _on_tree_entered() -> void:
# 	var timer =  get_tree().create_timer(0.1)
# 	timer.connect("timeout",func():
# 		print("计时器触发")
# 	)

## 跳转到道具列表
func _to_item():
	print("1111")
	window_item.show_and_active()

## 关闭道具窗口
func _item_back():
	window_item.hide_and_clear()

## 跳转到资料列表
func _to_lib():
	SceneManager.navigate_to("scene_lib")
