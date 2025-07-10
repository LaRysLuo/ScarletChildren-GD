extends Node
class_name GameVariable

var data_variable:DataVariable = preload("res://auto_load/data_variable/data_variable.gd").new()


## 全局变量
@export var _global_variable:Dictionary

## 事件开关 key为事件id，value是bool，表示启用过
@export var _event_switch:Dictionary 

## 信号
signal variable_changed


## 设置变量
func set_variable(_name:String,_value:bool):
    # 1. 判断数据中是否有这个变量
    var _config:Dictionary = data_variable.has_variable(_name)
    if _config.is_empty():
        push_error("不存在变量%s" % _name)
        return
    # 2. 将该变量写入字典中
    _global_variable[_name] = _value
    variable_changed.emit()

## 判断是否有这个变量
func has(_name:String,val:bool) -> bool:
    if !_global_variable.has(_name): return false == val
    return _global_variable.get(_name) == val

## 改变事件开关
func set_switch(event_id:String,val:bool):
    print("设置开关")
    _event_switch[event_id] = val
    print("开关=",_event_switch)
    

## 获取开关状态
func get_event_switch(event_id:String):
    print("开关=",_event_switch)
    return _event_switch.get(event_id)

func to_data():
    return {
        "global_variable":_global_variable,
        "event_switch":_event_switch,
    }

func from_data(_data:Dictionary) -> void:
    _global_variable = _data.get("global_variable")
    _event_switch = _data.get("event_switch")