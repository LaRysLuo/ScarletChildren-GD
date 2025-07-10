extends Control
class_name SceneMain

@onready var menuPanel = $MenuPanel
@onready var cmd_menu:MenuV2 = $MenuV2
@onready var bg_panel:Panel = $Panel
@onready var panel_bg:TextureRect = $PanelBg
@onready var window_item:WindowItem = $WindowItem


const cam_event_res = preload("res://scenes/ui_scene/scene_main/cam_event.tres")
const old_cam_event_res = preload("res://event_res/item_res/effect/02i_1_老式拍立得.tres")

@export var mapshot:Texture2D

var item_data:Dictionary:
	get: 
		var result = {}
		for item:Item in GameManager.game_items.get_items_catagory(1):
			result[item.item_id] = {
				"name": item.item_name,
				"desc": item.item_desc
			}
		return result

## 信号
signal on_cancel

## 初始化
func _ready() -> void:
	_init_window_item()
	_init_cmd_menu()

## 初始化道具列表窗口
func _init_window_item():
	window_item.set_items(item_data.values())

	window_item.on_select_changed.connect(func(): AudioManager.play_cursor_move())
	window_item.on_submit.connect(func():AudioManager.play_puzzle_complete())
	window_item.on_cancel.connect(_item_back)

## 初始化menuV2窗口
func _init_cmd_menu():
	cmd_menu.set_handler("item",_handle_item)
	cmd_menu.set_handler("camera",_handle_cam)
	cmd_menu.set_handler("cancel",_handle_cancel)
	cmd_menu.set_handler("load",_handle_load)
	AudioManager.play_se("Computer")
	cmd_menu.call_deferred("activate")

## 设置屏幕图片
func set_mapshot(_mapshot:Texture2D):
	panel_bg.texture =  _mapshot as Texture2D
	print_debug("texture:",_mapshot as Texture2D)
	self.mapshot = _mapshot

## 关闭该窗口
func _handle_cancel():
	UIManager.pop_ui(self)
	# on_cancel.emit(self)
	# SceneManager.backto()
	

## 跳转到道具列表
func _handle_item():
	cmd_menu.deactivate(false)
	window_item.show_and_active()

## 拍照功能
func _handle_cam():
	# 0. 退出主菜单
	UIManager.pop_all()
	# 等待恢复正常
	# GameManager.game_player.player.call_deferred("_has_interact_event",1)   #_has_interact_event()
	GameManager.trigger_event_res(old_cam_event_res)
	# GameManager.call_thread("trigger_event_res",old_cam_event_res)  #trigger_event_res(old_cam_event_res)
	# 1. 判断当前是否能拍照:
	# 2. Then: 要在镜子前拍照吗？多种照片随机选择
	# 3. ELSE: 退出

## 关闭道具窗口
func _item_back():
	cmd_menu.activate()
	window_item.hide_and_clear()

## 跳转到资料列表
func _handle_lib():
	pass
	# SceneManager.navigate_to("scene_lib")

func _handle_load():
	var scene:SceneLoad = await  UIManager.show_ui("scene_load")
	scene.show_with_load()
	# scene.on_confirm.connect(func():UIManager.pop_ui(scene))
	scene.on_cancel.connect(func(): cmd_menu.activate(),CONNECT_ONE_SHOT)
