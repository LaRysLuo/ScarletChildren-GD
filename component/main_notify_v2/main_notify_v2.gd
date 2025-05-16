extends Control
class_name MainNotifyV2

## 对外属性
@export var notify_list:Array[String]
@export var notify_time:float = 2

## 私有属性
var is_running:bool = false

const GAIN_ITEM = 1
const LOSE_ITEM = 0
const UPDATE_ITEM = 2


## 添加道具变化通知
## 获得/失去 
func add_item_notify(item_name:StringName,state:int = GAIN_ITEM):
	var show_info:String
	var obj:Dictionary = {}
	if state == UPDATE_ITEM:
		show_info = "[color=#A71460]%s[/color]的状态更新了" % item_name
	else:
		var gain_or_lose = "获得了" if state == 1 else "失去了"
		show_info = "%s物品" % [gain_or_lose]
		obj.show_info = show_info
		obj.item_name = item_name
		notify_list.push_back(obj)
	if !is_running: next_notify()


func next_notify():
	pass