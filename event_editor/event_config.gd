extends Resource
class_name EventConfig

# 用于判断该资源绑定的资源是否要显示
## 是否显示
@export var is_show:bool = true:
	set(val):
		print("is_show也变化了=",val)
		is_show = val
		event_visible_changed.emit(is_show)

## 事件条件：设置条件后，只会在指定条件时才会触发该事件
@export var condition:EventCondition

## 动画帧索引
@export var frame_index:int


# 为了绑定对应的事件点
## 坐标位置
@export var pos:Vector2i

# 
## 事件资源
@export var event_res:Events_Res
	
signal event_visible_changed(is_show:bool)
