extends Node
class_name GamePlay

## 枚举
enum GameState {
	Normal, #正在运行
	Buszing, #忙碌的
}


## 资源

# 物品提示框
var notify_prefab = preload("res://component/main_notify/main_ notify.tscn") # 通知预制体
var color_screen_pre:PackedScene = preload("res://component/color_rect/color_rect_full.tscn")

var config:PlayerConfig


## 信号
signal on_event_trigger_start # 事件开始时点
signal on_event_trigger_end #事件结束时点
signal on_buszing_finished ## 当忙碌状态结束了
signal on_player_loaded
signal on_player_ready #当玩家准备就绪

## 玩家场景
var game_state:GameState = GameState.Normal 

## 可存储类
var savable_list:Dictionary = {}


## 玩家
var player:PlayerV1:
	get(): return game_player.player


## 变量数据
@export var loaded_game_data:Dictionary


## 游戏数据类
@export var game_data:GameData = preload("res://auto_load/game_data/game_data.gd").new()
## 游戏玩家类
@export var game_player:GamePlayer = preload("res://auto_load/game_player/game_player.gd").new()
## 游戏道具类
@export var game_items:GameItems = preload("res://auto_load/game_items/game_items.gd").new()
## 游戏变量类
@export var game_variable:GameVariable = preload("res://auto_load/game_variable/game_variable.gd").new()

# @export var game_story:StoryFlagHandler = preload("res://scripts/core/story_flag/story_flag_handler.gd").new()

## 游戏时间类
@export var game_time:GameTime = preload("res://auto_load/game_time/game_time.gd").new()

## Steam成就类
@export var steam_achievement:SteamAchievement = preload("res://auto_load/steam_achievement/steam_achievement.gd").new()

## 是否为正常状态
var is_normal_state:bool:
	get(): return game_state == GameState.Normal

## 是否忙碌的
var is_buszing: bool:
	get(): return game_state == GameState.Buszing

func set_game_state_buszing():
	print("[GameManager]正在忙碌中")
	# get_tree().paused = true
	game_state = GameState.Buszing

func set_game_state_normal():
	# get_tree().paused = false
	game_state = GameState.Normal
	print("[GameManager]游戏状态变为正常")
	on_buszing_finished.emit()
	
func do_executable(): on_player_ready.emit()


#region 生命周期
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	set_game_state_buszing()
	#TranslationServer.set_locale('en')
	config = load("res://config/player_config.tres") 

	# 连接对话管理器
	DialogueManager.on_typing.connect(play_typing_se)
	
	## 初始化游戏数据类
	_init_game_data()

	# 初始化data_player
	_init_game_player()
	_init_game_items()
	_init_game_variable()
	_game_time()

	# _init_game_story()

	_init_steam()
	
   
   
	call_deferred("_load_game_data")


func _process(_delta: float) -> void:
	Steam.run_callbacks()



#endregion 

## 在_ready一帧后执行
func _load_game_data():
	# var _data = Save.load_data()
	# if _data && _data is Dictionary:
	#     loaded_game_data = _data 
	# # get_tree().paused = true
	pass

## 初始化游戏数据管理
func _init_game_data():
	self.add_child(game_data)

## 初始化游戏玩家类
func _init_game_player():
	game_player.on_player_loaded.connect(_on_player_loaded)
	savable_list["game_player"] = game_player
	
## 初始化游戏道具类
func _init_game_items():
	game_items.on_player_item_changed.connect(show_item_notify)
	game_items.initialize()
	savable_list["game_items"] = game_items

## 初始化游戏变量类
func _init_game_variable():
	savable_list["game_variable"] = game_variable

 # 初始化游戏时间
func _game_time():
	add_child(game_time)
	savable_list["game_time"] = game_time

## 初始化steam
func _init_steam():
	var initial:Dictionary  = Steam.steamInitEx(3770050)
	if initial['status'] > Steam.STEAM_API_INIT_RESULT_OK:
		print("Failed to initialize Steam, shutting down: %s" % initial)
		get_tree().quit()
		return
	print("[Steam]初始化成功")
	Steam.current_stats_received.connect(_on_steam_stats_ready,CONNECT_ONE_SHOT)
	Steam.user_stats_received.connect(_on_steam_stats_ready)
	var is_owned = Steam.isSubscribed()
	if !is_owned:
		print('[Steam]你没有拥有该游戏')
		get_tree().quit()
	# steam_achievement.test_remove_achievement("01_WELCOME_TO_SCARLETMANOR")
	steam_achievement.load_all_achievenment_from_steam()



func _on_player_loaded():
	# 初始化完毕，使游戏开始运行
	print("[GameManager]玩家初始化完成")
	set_game_state_normal()
	
	on_player_loaded.emit()

func _on_steam_stats_ready(game_id: int, result: int, user_id: int):
	print("[Steam]game_id=%s,result=%s,userid=%s",[game_id,result,user_id])
	steam_achievement.load_all_achievenment_from_steam()


## 事件开始的回调函数
func _event_trigger_start():
	print("[GM]开始繁忙")
	set_game_state_buszing()
	on_event_trigger_start.emit()

## 事件结束的回调函数
func _event_trigger_end():
	print("[GM]恢复正常")
	set_game_state_normal()
	on_event_trigger_end.emit()

## 播放打字声音
func play_typing_se():
	AudioManager.play_se("pushing_a_key")

	
#func remove_item()

## 获取notify实例
func create_notify() -> MainNotify:
	var filters = get_children().filter(func(item):return item is MainNotify)
	var notify_entity
	if filters.is_empty():
		notify_entity = notify_prefab.instantiate()
		add_child(notify_entity)
	else: notify_entity = filters[0]
	return notify_entity


## 显示道具通知
func show_item_notify(item_name,state):
	# 创建道具获取通知
	create_notify().add_item_notify(item_name,state)


var color_screen:ColorScreen

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
	

## 移动事件去pos
func move_event_to(char_name:StringName,target_pos:Vector2i):
	var ent = get_character(char_name)
	if ent: ent.set_pos(target_pos)

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

## 显示事件 封装
func show_ent_tween(char_name:StringName,time:float =  0.3):
	set_ent_visible(char_name,true)
	#await get_tree().process_frame
	
	get_character(char_name).modulate.a = 0
	#print("cccc=",get_character(char_name).self_modulate)
	await  _set_ent_tween(char_name,true,time)

## 隐藏事件 封装
func hide_ent_tween(char_name:StringName,time:float =  0.3):
	await _set_ent_tween(char_name,false,time)
	
## INFO 渐变显示隐藏事件
# 该显示和隐藏不会持久化	
func _set_ent_tween(char_name:StringName,is_show:bool,time:float):
	var character = get_character(char_name)
	var tween:Tween = create_tween()
	var count:float = 1 if is_show else 0
	tween.tween_property(character,"modulate:a",count,time)
	await  tween.finished
	if is_show:
		character.show()
	else:
		character.hide()

## 解析名字为事件实例
func parse_event_name(event_name:StringName) :
	if event_name == "player":
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

## 设置玩家面朝方向
func face_to(dir:Vector2i):
	self.player.dir = dir
	self.player.execute_animation()

## 获得当前场景的地图
func get_map_config() -> MapConfig:
	return get_tree().current_scene.get_node("Maps") as MapConfig


## 等待
## TODO 后期转到工具类
func wait(time:float):
	await  get_tree().create_timer(time).timeout

	 
## 触发事件的封装
func trigger_event_res(event_res:Events_Res,trigger_self:Event = null,args= {}):
	#if !GameManager.is_normal_state: return
	## Q: 为什么这里要使用on_event_trigger_start.emit()，而不是直接放到set_game_state_buszing
	## A: 这个on_event_trigger_start和on_event_trigger_end本身只表示事件触发开始时点和事件触发结束时点，
	##    不是表示事件忙碌状态得结束
	## 但是确实发现，这样写有点奇怪，所以现在进行了改版25.6.7

	_event_trigger_start()
	var event:BaseEventNode = event_res.tree
	## WARNING 事件处理主逻辑
	## 如果需要添加新的节点逻辑，请去对应继承BaseEventNode的子类去重写_execute
	## 新建一个自定义的事件线程（不是真的线程，可以叫协程或者序列）来处理所有事件，并等待处理完成
	var et = EventThread.new()
	await et.trigger_event(event,trigger_self,args).on_complete
	_event_trigger_end()
	

	
