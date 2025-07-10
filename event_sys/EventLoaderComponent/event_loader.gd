extends Node2D
class_name EventLoader

## 事件加载器
# 按照事先编排好的事件节点，进行读取操作

## 当EventLoader是不可见时，不会运行该脚本
@export_group("资源")
## 自动执行该资源，如果没有资源将不会执行
@export var event_res:Events_Res

## 初始化,开始执行事件
func _ready() -> void: 
    if !visible:
        return
    print("[EventLoader]运行了")
    if !event_res:
        Larik.warn("[EventLoader]出错了，未设置event_res")
        return
    _trigger()

## 触发事件效果
func _trigger() -> void:
    visible = false
    GameManager.trigger_event_res(event_res)

