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

var all_events:Array[Node] 

## 获得移动层
var movable:TileMapLayer:
	get():return get_node("Movable")

#var tile_black:TileMapLayer

func _ready() -> void:
	
	self.hide()
	movable.hide()
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
	all_events  = get_tree().get_nodes_in_group("events")
		## 同时进行可视度的判断,将当前不可视的隐藏
		## 并且连接信号
	for event:Event in all_events:
		var config:EventConfig = get_event(event.ori_cell_pos)
		#print("config=",conf)
		if config:
			var is_show:bool = config.is_show && event.activable(config)
			print("is_show111=",is_show)
			refresh_event_visible(is_show,event)
			config.event_visible_changed.connect(refresh_event_visible.bind(event))

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
	## INFO 这里增加了当游戏忙碌时，延后x秒再执行
	if GameManager.game_state == GameManager.GameState.Buszing:
		await  GameManager.on_event_trigger_end
		await  get_tree().create_timer(0.6).timeout
	print("正在执行自动事件")
	#print("all_events=",all_events)
	# 筛选出地图上的event
	var auto_events:Array[Node] = all_events.filter(func(event:Event):return event.can_auto_trigger())
	print("自动执行事件数量：",auto_events.size())
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
			return item.pos == coord && get_condition_result(item)
	)
	print("filters=",filter.size())
	if filter.is_empty():return null
	return filter.front()
	
## 传入角色名称获取角色
func get_event_coord_by_name(char_name:StringName) -> Vector2i:
	var filters =	get_tree().get_nodes_in_group("characters").filter(func(char:Event):return char.event_name == char_name)
	if filters.is_empty():
		return Vector2i(-1,-1)
	return filters.front().ori_cell_pos

## INFO 2025.1.31修改 - 改为复数条件
func get_condition_result(item:EventConfig) -> bool:
	return item.get_condition_result()
	#if item.condition && !item.condition.is_empty():
		#return item. #.condition._get_result()
	#return true
