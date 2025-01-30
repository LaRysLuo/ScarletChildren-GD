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


#var tile_black:TileMapLayer

func _ready() -> void:
	
	self.hide()
	
	#_init_scene_event()
	## 增加一个画面显示前的处理
	await  _map_show_pre()
	self.show()
	#tile_black = $Black
	#if tile_black: tile_black.show()
	#if SceneManager.is_running:
		#await SceneManager.move_finished
	## 做本场景的事件初始化
	call_deferred("_init_scene_event")
	call_deferred("auto_event_trigger")

## 初始化地图的事件
func _init_scene_event():
	pass
	#var all_events = get_tree().get_nodes_in_group("events")
	#for event:Event in all_events:
		#var config = get_event(event.cell_pos)
		#if !config || !config.event_res:
			#printerr("有事件没有配置event_res:%s，坐标是：%s" % [event.name,event.cell_pos])
			#continue
		#event.ingore_collsion = !config.event_res.is_collsion

## 增加一个游戏初始化前
func _map_show_pre():
	pass
	# 获取所有的character
	#if map_pre_event: 
		#await GameManager.trigger_event_code(map_pre_event,null)

# 1. 事件的可视度判断
# 2. 自动事件的触发
## 自动事件的触发
func auto_event_trigger():
	print("正在执行自动事件")
	var all_events:Array[Node] = get_tree().get_nodes_in_group("events")
	## 同时进行可视度的判断,将当前不可视的隐藏
	## 并且连接信号
	for event:Event in all_events:
		var config = get_event(event.cell_pos)
		if !config:continue
		var is_show:bool = config.is_show && event.activable(config)
		refresh_event_visible(is_show,event)
		config.event_visible_changed.connect(refresh_event_visible.bind(event))
	#print("all_events=",all_events)
	# 筛选出地图上的event
	var auto_events:Array[Node] = all_events.filter(func(event:Event):return event.can_auto_trigger())
	
	## 遍历这些自动事件执行
	for event in auto_events:
		if event is Event:
			print("检测到自动事件：",event.get_instance_id())
			await event.interact()

## 改变指定坐标的事件状态
func set_event_visible(coord:Vector2i,is_show:bool):
	var config  = get_event(coord)
	print("config=",config)
	config.is_show = is_show

## 刷新event的可视状态
func refresh_event_visible(is_show:bool,event:Event):
	print("event的状态变化了",is_show)
	event.visible = is_show

## 传入坐标获取事件
func get_event(coord:Vector2i) -> EventConfig:
	## 没有配置任何事件的情况
	if event_group.is_empty():
		return null
	var filter = event_group.filter(
		func(item:EventConfig): 
			return item.pos == coord && (item.condition && item.condition._get_result())
	)
	print("filters=",filter.size())
	if filter.is_empty():return null
	return filter.front()
