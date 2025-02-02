extends CanvasLayer
class_name GamePlay

enum GameState {
	Normal, #正在运行
	Buszing, #忙碌的
}

enum Balloon{
	Angry,	
}

var game_state = GameState.Normal 
var player_pre:Resource
var player:Player_v1

var config:PlayerConfig
var color_screen_pre:PackedScene


## 信号
signal on_event_trigger_start
signal on_event_trigger_end
signal on_event_reload(event:Event) # 重载入事件状态

## 玩家场景


## 玩家位置

## 预制体
var notify_prefab = preload("res://component/main_notify/main_ notify.tscn")


@export var data_variable:DataVariable = preload("res://auto_load/data_variable/data_variable.gd").new()
@export var data_player:DataPlayer = preload("res://auto_load/data_player/data_player.gd").new()
@export var game_time:GameTime = preload("res://auto_load/game_time/game_time.gd").new()

var is_normal_state:
	get(): return game_state == GameState.Normal

func set_game_state_buszing():
	game_state = GameState.Buszing

func set_game_state_normal():
	game_state = GameState.Normal
	print("游戏状态变为正常")


# 记录游戏的状态
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_game_state_buszing()
	#TranslationServer.set_locale('en')
	color_screen_pre = preload("res://component/color_rect/color_rect_full.tscn")
	player_pre = preload("res://character/player.tscn")
	config = load("res://config/player_config.tres") 
	#data_variable.game_progress
	DialogueManager.on_typing.connect(play_typing_se)
	data_player.load_items()
	data_player.load_items_raw()
	# 连接道具通知的信号
	data_player.on_player_item_changed.connect(show_item_notify)
	#print("data_player=",data_player.items)
	
	add_child(game_time)
	
	on_event_trigger_start.connect(_event_trigger_start)
	on_event_trigger_end.connect(_event_trigger_end)
	
	## 载入游戏数据 TODO 实际不能在这里调用
	SceneManager.move("res://scenes/maps/蔷薇馆·西馆走廊2F/map_蔷薇馆·西馆走廊2f.tscn",Vector2i(8,12),true,true)
	##return

	
	#await  SaveManager.load_data()
	await get_tree().create_timer(0.5).timeout
	#GameManager.data_player.gain_item("06i_3_手电筒（魔法灯）")
	#GameManager.data_player.gain_item("301f_0_羽新的日记")
	#GameManager.data_player.gain_item("103i_0_5号电池")
	#GameManager.data_player.gain_item("203c_0_隐藏蔷薇合照已调查")
	#GameManager.data_player.gain_item("06i_4_手电筒（魔法灯有电池）")
	GameManager.data_player.gain_item("204c_0_隐藏幽灵门启动")
	
	set_game_state_normal()

func _event_trigger_start():
	set_game_state_buszing()

func _event_trigger_end():
	set_game_state_normal()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_typing_se():
	AudioManager.play_se("pushing_a_key")
	pass

var color_screen:ColorScreen
## set_screen_color(ColorScreen.BLACK)

## 相机移动
func camera_move():
	var camera:Camera2D = get_main_camera()
	if !camera:
		print_debug("没有找到camera")
		return
	print("camera=",camera)
	var tween:Tween = get_tree().create_tween()
	var camera_pos = Vector2(0,camera.offset.y - 200)
	tween.tween_property(camera,"offset",camera_pos,4)
	await tween.finished

## 重置摄像机
func reset_camera(with_tween:bool = true):
	var cam = get_main_camera()
	if !cam:
		print_debug("没有找到camera")
		return
	if with_tween:
		var tween:Tween = get_tree().create_tween()
		tween.tween_property(cam,"offset",Vector2.ZERO,0.8)
		await  tween.finished
	else: cam.offset = Vector2.ZERO

## 获得主摄像机
func get_main_camera() -> Camera2D:
	if !GameManager.player: return null
	return GameManager.player.cam
	#var scene = get_tree().current_scene
	#if scene:
		#return scene.get_node_or_null("Camera2D")
	#return null

## INFO 获得道具
## 通过item的key值获得对应的item
func gain_item(item_key:String):
	data_player.gain_item(item_key)
	
#func remove_item()

## 获取notify实例
func create_notify() -> MainNotify:
	var filters = get_children().filter(func(item):return item is MainNotify)
	var notify_entity
	if filters.is_empty():
		notify_entity = notify_prefab.instantiate()
		self.add_child(notify_entity)
	else: notify_entity = filters[0]
	return notify_entity

func show_item_notify(item_name,state):
	create_notify().add_item_notify(item_name,state)



## 设置屏幕颜色
## ColorScreen.Black
# set_screen_color(ColorScreen.Black)
func set_screen_color(color:Color):
	if color_screen: clear_screen()
	color_screen = color_screen_pre.instantiate()
	if color_screen is ColorScreen:
		color_screen.set_color(color)
	add_child(color_screen)
	
## 淡出黑色
func fadeout_black(time:float = 1):
	if color_screen: clear_screen()
	color_screen = color_screen_pre.instantiate()
	add_child(color_screen)
	if color_screen is ColorScreen:
		color_screen.set_color(ColorScreen.BLACK,true,time)
	await color_screen.fade_finished
	
## 淡入画面
func fadein(time:float = 1):
	if color_screen:
		await color_screen.fadein(time)
		color_screen = null

func clear_screen():
	if color_screen: 
		color_screen.clear()
		color_screen = null

## 显示表情:self表示player玩家，其他玩家时
func show_balloon(char_name:String,balloon_name:StringName):
	var result:CharacterBase
	result = parse_event_name(char_name)
	if !result: 
		printerr("出错了:%s" % "事件名不能为空")
		return
	await result.play_balloon(balloon_name)
	#set_game_state_normal()

## 隐藏玩家
func hide_event(event_name:StringName):
	var event:CharacterBase
	event = parse_event_name(event_name)
	if !event:
		printerr("出错了，事件不能为空")
		return
	event.hide()

## 显示角色的故障效果
func char_show_glitch(char_name:StringName,time = 0.1,dur_time:float = 0.01):
	var character = get_character(char_name)
	if !character:return
	AudioManager.play_fault()
	await  character.show_glitch(time,dur_time)

func char_hide_effect(char_name:StringName):
	var character = get_character(char_name)
	if !character:return
	character.hide_glitch()

func get_character(char_name:StringName):
	var map_config:MapConfig = get_map_config()
	if !map_config:return null
	var ent:Event = map_config.get_event_by_name(char_name)
	return ent
	
	

## 设置事件的可视状态
func set_event_visible(coord:Vector2i,is_show:bool):
	#GameManager.set_event_visible(Vector2i(21,5),true)
	## 先找出当前场景的MapConfig
	var map_config:MapConfig = get_map_config()
	print("map_config=",map_config)
	map_config.set_event_visible(coord,is_show)

## 通过事件的名称设置事件可视状态
func set_ent_visible(char_name:StringName,is_show:bool):
	var map_config:MapConfig = get_map_config()
	map_config.set_event_visible_by_name(char_name,is_show)


## 解析名字为事件实例
func parse_event_name(event_name:StringName) :
	if event_name == "sefl":
		return player
	if event_name == "":
		return null
	var filter =  get_tree().get_nodes_in_group("events").filter(
			func(item):return item.event_name == event_name
		)
	if filter.is_empty():
		printerr("出错了，没有匹配到该名字事件")
		return
	return filter[0]
	pass

## 设置玩家面朝方向
func face_to(dir:Vector2i):
	self.player.dir = dir
	self.player.execute_animation()

#func _get_event(label) -> CharacterBase:
	#var tilemaplayer:TileMapLayer = ent.get_parent()
	#
	#var value = target_char['coord']
	#var label = target_char['label']
	#if typeof(value) == TYPE_STRING: 
		#if value == "this": return ent ## 当目标角色是0时，表示事件自己
		#if value ==  "player": return GameManager.player as CharacterBase ## 当目标角色是1时，表示玩家
	#if typeof(value) == TYPE_VECTOR2I:
		#var group = tilemaplayer.get_tree().get_nodes_in_group("events")
		#var filters = group.filter(func(item:Event):return item.event_name == label)
		#if filters.is_empty():return null
		#return filters[0]
	#return null

## 获得当前场景的地图
func get_map_config() -> MapConfig:
	return get_tree().current_scene.get_node("Maps") as MapConfig

# 创建玩家
func instance_player(map:Node2D,vec:Vector2):
	if player: print_debug("初始化玩家错误，当前已生成玩家，请确认整个游戏玩家标识是否只有1个")
	if !player_pre: print_debug("初始化玩家失败，未设置玩家场景的路径")
	player = player_pre.instantiate() 
	player.position = vec
	player.start_pos_changed.connect(update_fog)
	map.add_child(player)
	movable = map.get_parent().get_node("./Movable")
	#block_map = map.get_parent().get_node("./Black")
	#call_deferred("update_fog") 

## 临时在这个类里先写地图管理类
## 1. 首先获得玩家类
## 2. 驱散玩家周围的迷雾
## 3. 注册玩家移动的信号，更新迷雾状态

var block_map:TileMapLayer
var movable:TileMapLayer
var blocks:Array[Node]
var is_completed:Array = [] ## 表示已经隐藏的图块
var timer:SceneTreeTimer
var dirs = [
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i(1,1),
	Vector2i(-1,-1),
	Vector2i(1,-1),
	Vector2i(-1,1)
]
var index:int = 0

## 更新地图迷雾
## 在地图的Tilemap上要配置上迷雾图块
## TODO 或许可以放到一个专门的文件里
func update_fog():
	## 检查玩家配置是否存在
	if !config:
		printerr("未配置player_config")
		return
		
	## 获得block_map
	if !block_map || !block_map.visible:
		return
	var vision_range:int = config.vision_range
	var player_pos := movable.map_to_local(player.cell_pos) 
	var pos = block_map.local_to_map(player_pos)
	flood_fill_circle(pos,vision_range)
	
	
## 用洪水填充移出地图上的地图迷雾
func flood_fill_circle(center:Vector2i,radius:int):
	var queue:Array = [center]
	var next_list:Array = []
	var visited = {}
	for r in range(radius):
		if queue.is_empty():
			queue.append_array(next_list)
			next_list = []
		while queue.size() > 0:
			var pos = queue.pop_front()
			if pos in visited  or get_antiglare(pos):
				continue
			visited[pos] = true
			
			
			var black_state = Vector2i(3,0)
			
			if r >= radius -2 && r  < radius:
				black_state = Vector2i(1,0)
			if r >= radius - 4 && r < radius -2:
				black_state = Vector2i(2,0)
			block_map.set_cell(pos,0,black_state)
			is_completed.append(pos) ## 把已经照亮的区域存起来
			
			for dir in dirs:
				if abs(dir.x)  == abs(dir.y) and r <= 2:
					continue 
				var next = pos + dir
				next_list.append(next)
		await  wait(0.01)
	
	var unlighting = is_completed.filter(func(item:Vector2i):return item not in visited)
	
	for pos in unlighting:
		block_map.set_cell(pos,0,Vector2i(0,0))
		is_completed.erase(pos)

## 等待
## TODO 后期转到工具类
func wait(time:float):
	await  get_tree().create_timer(time).timeout

## 判断是否是遮光体
## TODO 需要重新制作遮光体的内容，在地图上获取的标识现在还是32像素的，也要改成8像素的
func get_antiglare(coord:Vector2i) ->bool:
	var position =	block_map.map_to_local(coord)
	var new_coord = movable.local_to_map(position)
	var tile_data = movable.get_cell_tile_data(new_coord)
	#print("遮光：",tile_data && tile_data.get_custom_data("antiglare") )
	if tile_data && tile_data.get_custom_data("antiglare"):return true
	return false

## WARNING 已弃用
func get_black(coord:Vector2i) -> Black:
	var blocks = block_map.get_children()
	var results = blocks.filter(func(item:Black):return item.cell_pos == coord)
	if results && !results.is_empty():
		return results[0] as Black
	return null
	 
## 触发事件的封装
func trigger_event_res(event_res:Events_Res,trigger_self:Event = null,args= {}):
	on_event_trigger_start.emit()
	var event:BaseEventNode = event_res.tree
	## WARNING 事件处理主逻辑
	## 如果需要添加新的节点逻辑，请去对应继承BaseEventNode的子类去重写_execute
	#await trigger_event(event,trigger_self)
	## 新建一个自定义的事件线程（不是真的线程，可以叫协程或者序列）来处理所有事件，并等待处理完成
	var et = EventThread.new()
	await et.trigger_event(event,trigger_self,args).on_complete
	set_game_state_normal()
	on_event_trigger_end.emit()

## WARNING 已弃用，转为使用自定义事件线程
## 触发事件封装
func trigger_event(event:BaseEventNode,trigger_self:Event):
	while(true):
		event = event.next()
		if !event: 
			print("循环结束")
			break
		await event._execute(trigger_self,null) # 执行事件节点的逻辑
	
