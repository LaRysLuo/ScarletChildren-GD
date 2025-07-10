extends Node2D
class_name MapConfig

@export var top_limit:float
@export var bottom_limit:float
@export var left_limit:float
@export var right_limit:float

## 地图上的事件配置
@export var event_group:Array[EventConfig]

## 地图上的特殊事件配置列表
@export var event_ex:Array[EventExConfig]

@export var map_pre_event:Events_Res

# @export var is_loaded:bool = false ## 实在载入完成

var all_events:Array[Node]  = []


var event_pages_handler:EventPageHandler:
	get: return get_parent().get_node("EventPages")


## 获得移动层
var movable:TileMapLayer:
	get():return get_node("Movable")

#var tile_black:TileMapLayer

func _ready() -> void:
	print("[MapConfig]正在初始化")
	# is_loaded = true
	# print("is_loaded=",is_loaded)
	self.hide()
	_get_movable().hide()
	self.show()
	call_deferred("auto_event_trigger")
	visibility_changed.connect(_reload_event_config)
	

## 获得移动层
func _get_movable() -> TileMapLayer:
	return get_node("./Movable")

## 重新加载事件配置
func _reload_event_config():
	if !get_parent().visible: return
	print("重新加载了事件配置=",get_parent().name)
	for ent:Event in all_events:
		ent._load_event_config()
	pass


# 1. 事件的可视度判断
# 2. 自动事件的触发
## 自动事件的触发
func auto_event_trigger():
	## INFO 这里增加了当游戏忙碌时，等待忙碌结束
	if GameManager.is_buszing:
		print("[MapConfig]GameManager忙碌中，等待忙碌结束")
		await  GameManager.on_buszing_finished
		await  get_tree().create_timer(0.1).timeout
	print("[MapConfig]正在执行自动事件")
	if all_events.is_empty(): all_events = get_tree().get_nodes_in_group("events")
	# 筛选出地图上的event
	var auto_events:Array[Node] = all_events.filter(func(event:Event):return event.can_auto_trigger())
	print("自动执行事件数量：",auto_events.size())
	## 遍历这些自动事件执行
	for event in auto_events:
		if event is Event:
			await event.interact()
	await  get_tree().create_timer(0.5).timeout

## 改变指定坐标的事件状态
func set_event_visible(coord:Vector2i,is_show:bool):
	var config  = get_event(coord)
	config.is_show = is_show
	
func set_event_visible_by_name(char_name:StringName,is_show:bool):
	var coord = get_event_coord_by_name(char_name)
	if coord == Vector2i(-1,-1): 
		printerr("无法获得角色%s" % char_name)
		return 
	var config = get_event(coord)
	if !config:
		printerr("无法获得角色%s" % char_name)
		return
	config.is_show = is_show



## 刷新event的可视状态
#func refresh_event_visible(is_show:bool,event:Event):
	#var _is_show:bool = is_show && event.activable(event.get_event_config())
	#event.visible = _is_show

## 传入坐标获取事件配置
func get_event(coord:Vector2i,ignore_condition:bool = false) -> EventConfig:
	## 没有配置任何事件的情况
	if event_group.is_empty():
		return null
	
	var filter = event_group.filter(
		func(item:EventConfig): 
			## INFO 2025.1.31修改 - 改为复数条件
			return item.pos == coord && (item.get_condition_result() || ignore_condition)
	)
	print("filters=",filter.size())
	if filter.is_empty():return null
	return filter.front()




## 获得对应名称的的Event
func get_event_by_name(char_name:StringName) -> Event:
	if all_events.is_empty():return null
	var filters =  all_events.filter(func(item:Event): return "characters" in item.get_groups() && item.event_name == char_name)
	if filters.is_empty():return null
	return filters.front()
	
## 传入角色名称获取角色
func get_event_coord_by_name(char_name:StringName) -> Vector2i:
	var filters =	get_tree().get_nodes_in_group("characters").filter(func(_char:Event):return _char.event_name == char_name)
	if filters.is_empty():
		return Vector2i(-1,-1)
	return filters.front().ori_cell_pos


#func get_condition_result(item:EventConfig) -> bool:
	#return item.get_condition_result()
	##if item.condition && !item.condition.is_empty():
		##return item. #.condition._get_result()
	##return true
