extends BasePage
class_name EventPage

## 事件页

## 对应的坐标
@export var pos:Vector2i 

## 触发条件：请不要使用EventCondition基类
@export var condition:Array[EventCondition] 

## 是否可见
@export var is_show:bool:
    set(val):
        print("is_show也变化了=",val)
        is_show = val
        event_visible_changed.emit(is_show)


## 动画索引帧
@export var frame_index:int:
    set(val):
        frame_index = val
        need_refresh = true

## 事件资源
@export var content:Events_Res 


## 描述这个事件页的作用
@export_multiline  var desc:String

## 需要更新的状态
var need_refresh:bool  = false

signal event_visible_changed(is_show:bool)


## INFO 2025.1.31修改 - 改为复数条件
## 获得条件的结算结果
func get_condition_result() -> bool:
    ## 判断条件是否全部满足，如果全部符合条件则返回true
    return condition.all(func(condi:EventCondition): return condi._get_result())
