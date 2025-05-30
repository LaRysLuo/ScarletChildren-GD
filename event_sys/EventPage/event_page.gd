@tool
@icon("res://assets/icon/thunder.png")
extends BasePage
class_name EventPage

## 事件页

## 对应的坐标
@export var pos:Vector2i:
    set(val):
        pos = val
        
        _init_pos()


## 触发条件：请不要使用EventCondition基类
@export var condition:Array[EventCondition] 

## 该事件是否有效
@export var enable:bool = true

## 是否可见，改为单纯不显示图像
@export var is_show:bool:
    set(val):
        print("is_show也变化了=",val)
        is_show = val
        event_visible_changed.emit(is_show)

## 角色
# @export var character:PackedScene

## 精灵图
# @export var sprite:Sprite2D

@export_enum( "Down", "Left", "Right","Up")
var dir: int:
    set(val):
        dir = val

# var dir: Vector2i = Vector2i.ZERO
## 动画索引帧
@export var frame_index:int:
    set(val):
        frame_index = val
        need_refresh = true

## 事件资源
@export var content:Events_Res 


## 描述这个事件页的作用
@export_multiline  var desc:String


var handler:Node2D:
    get: return get_parent()

var maps:TileMapLayer:
    get: return handler.get_parent().get_node("Maps/Objects")

## EDITOR ONLY
func _init_pos():
    if !Engine.is_editor_hint(): return
    self.position = maps.map_to_local(pos)

## 需要更新的状态
var need_refresh:bool  = false

signal event_visible_changed(is_show:bool)


## INFO 2025.1.31修改 - 改为复数条件
## 获得条件的结算结果
func get_condition_result() -> bool:
    ## 判断条件是否全部满足，如果全部符合条件则返回true
    return condition.all(func(condi:EventCondition): return condi._get_result())


