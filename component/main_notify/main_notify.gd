extends CanvasLayer
class_name MainNotify

## 组件引用
@onready var root:Control = $HBoxContainer
@onready var rich_label:RichTextLabel = $HBoxContainer/Panel/MarginContainer/HBoxContainer/Label

## 属性
@export var notify_list:Array[String]
@export var notify_time:float = 2

const GAIN_ITEM = 1
const LOSE_ITEM = 0
const UPDATE_ITEM = 2

var is_running:bool = false


## 添加道具变化通知
## 获得/失去 
func add_item_notify(item_name:StringName,state:int = GAIN_ITEM):
	var show_info:String
	if state == UPDATE_ITEM:
		show_info = "[color=#A71460]%s[/color]的状态更新了" % item_name
	else:
		var gain_or_lose = "获得" if state == 1 else "失去"
		show_info = "%s了[color=#A71460]%s[/color]" % [gain_or_lose,item_name]
	notify_list.push_back(show_info)
	if !is_running: next_notify()

## 添加notify
func add_notify():
	pass

## 执行下一个通知
func next_notify():
	if notify_list.is_empty():
		## 全部执行完成
		#queue_free()
		is_running =false
		return
	is_running = true
	var notify_info = notify_list.pop_front()
	## 1. 更换notify_text
	rich_label.text = notify_info
	## 2. 移入画面
	var tween = get_tree().create_tween()
	var pos1 = Vector2(500,20)
	var pos2 = Vector2(800,20)
	root.position = pos2
	tween.tween_property(root,"position",pos1,0.2)
	await tween.finished
	## 3. 等待一段时间后
	await get_tree().create_timer(notify_time).timeout
	var tween2 = get_tree().create_tween()
	tween2.tween_property(root,"position",pos2,0.4)
	await tween2.finished
	await get_tree().create_timer(0.2).timeout
	next_notify()
