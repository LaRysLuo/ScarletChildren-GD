extends Node2D
class_name DataVariable

## 游戏里的变量

## 游戏进度
var game_progress:int

## 事件开关 key为事件id，value是bool，表示启用过
var _event_switch:Dictionary 

## 改变事件开关
func set_switch(event_id:String,val:bool):
	print("设置开关")
	_event_switch[event_id] = val
	print("开关=",_event_switch)
	

## 获取开关状态
func get_event_switch(event_id:String):
	print("开关=",_event_switch)
	return _event_switch.get(event_id)
