extends Resource
class_name Item

## 编号，要保证唯一
@export var item_id:StringName
## 道具名称
@export var item_name:StringName
## 道具分类
@export var item_catagory:int ## 1表示道具 2表示线索
## 道具描述
@export var item_desc:String

## 道具状态,表示已更新
@export var is_finished:bool  = false

## 使用的事件 如果没有该事件，该道具不能使用
@export var use_event:Callable
@export var use_event_new:EventsRes
@export var err_desc:String





@export var relations:Array[Item]


## 使道具变为下一个道具
func next_relation():
	
	pass
