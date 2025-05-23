@tool
extends Resource
class_name EventConfig

# 用于判断该资源绑定的资源是否要显示
## 是否显示
@export var is_show:bool = true:
	set(val):
		print("is_show也变化了=",val)
		is_show = val
		event_visible_changed.emit(is_show)

## INFO 2025.1.31修改 将condition改为数组
## 事件条件：设置条件后，只会在指定条件时才会触发该事件
@export var condition:Array[EventCondition]

## 动画帧索引
@export var frame_index:int:
	set(val):
		frame_index = val
		need_refresh = true
		
var need_refresh:bool = false

# 为了绑定对应的事件点
## 坐标位置
@export var pos:Vector2i:
	set(val):
		pos = val
		if Engine.is_editor_hint(): self.resource_name = "(%s,%s)" % [pos.x,pos.y]

# 
## 事件资源
@export var event_res:Events_Res
	
signal event_visible_changed(is_show:bool)

## INFO 2025.1.31修改 - 改为复数条件
## 获得条件的结算结果
func get_condition_result() -> bool:
	## 判断条件是否全部满足，如果全部符合条件则返回true
	return condition.all(func(condi:EventCondition): return condi._get_result())
