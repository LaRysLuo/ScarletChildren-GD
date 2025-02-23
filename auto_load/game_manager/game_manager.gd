extends CanvasLayer

## 枚举
# enum GameState {
# 	Normal, #正在运行
# 	Buszing, #忙碌的
# }

enum Balloon{
	Angry,	
}


## 资源
var player_pre:Resource = preload("res://character/player.tscn") # 玩家预制体
var notify_prefab = preload("res://component/main_notify/main_ notify.tscn") # 通知预制体


var config:PlayerConfig


## 引用组件
@onready var audio_player:AudioPlayer = get_node("AudioPlayer") # 音频播放器
@onready var dialogue_manager:DialogueSystem = get_node("DialogueSystem") # 对话框管理器
@onready var scene_manager:SceneManager = get_node("SceneManager") #

## 信号
signal on_event_trigger_start
signal on_event_trigger_end


## 玩家场景
# var game_state = GameState.Normal 



@export var data_variable:DataVariable = preload("res://auto_load/data_variable/data_variable.gd").new()
@export var data_player:DataPlayer = preload("res://auto_load/data_player/data_player.gd").new()
@export var game_time:GameTime = preload("res://auto_load/game_time/game_time.gd").new()

var is_normal_state:
	get(): return true  #game_state == GameState.Normal

func set_game_state_buszing(): pass
	# game_state = GameState.Buszing

func set_game_state_normal(): pass
	# game_state = GameState.Normal


func _ready() -> void:
	set_game_state_buszing()
	#TranslationServer.set_locale('en')
	config = load("res://config/player_config.tres") 

	## 初始化对话框系统
	_init_dialogue_system()
	
	# 初始化data_player
	_init_data_player()
	
	# 初始化游戏时间
	add_child(game_time)
	
	# 连接信号：这些信号是为了事件触发开始时点和结束时点的信号
	on_event_trigger_start.connect(set_game_state_buszing)
	on_event_trigger_end.connect(set_game_state_normal)
	
	## 载入游戏数据 TODO 实际不能在这里调用
	#SceneManager.move("res://scenes/maps/蔷薇馆·西馆走廊2F/map_蔷薇馆·西馆走廊2f.tscn",Vector2i(8,12),true,true)
	##return
	#await  SaveManager.load_data()
	#await get_tree().create_timer(0.5).timeout
	#GameManager.data_player.gain_item("06i_3_手电筒（魔法灯）")
	#GameManager.data_player.gain_item("301f_0_羽新的日记")
	#GameManager.data_player.gain_item("103i_0_5号电池")
	#GameManager.data_player.gain_item("203c_0_隐藏蔷薇合照已调查")
	#GameManager.data_player.gain_item("205c_0_追逐怪出现")
	#GameManager.data_player.gain_item("206c_0_二楼电力恢复")
	
	#set_game_state_normal()

## 初始化对话框系统
func _init_dialogue_system():
	# 连接信号：当打字时，播放音乐
	dialogue_manager.on_typing.connect(audio_player.play_se.bind("pushing_a_key"))

## 初始化角色数据
func _init_data_player():
	data_player.load_items_at_start()
	data_player.load_items_raw()
	data_player.on_player_item_changed.connect(show_item_notify)


## INFO 获得道具
## 通过item的key值获得对应的item
func gain_item(item_key:String):
	data_player.gain_item(item_key)
	

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
	audio_player.play_fault()
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
	if event_name == "sefl":
		# return player
		return null
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

## 获得当前场景的地图
func get_map_config() -> MapConfig:
	return get_tree().current_scene.get_node("Maps") as MapConfig




## 等待
## TODO 后期转到工具类
func wait(time:float):
	await  get_tree().create_timer(time).timeout

	 
## 触发事件的封装
func trigger_event_res(event_res:EventsRes,trigger_self:Event = null,args= {}):
	var event:BaseEventNode = event_res.tree
	## WARNING 事件处理主逻辑
	## 如果需要添加新的节点逻辑，请去对应继承BaseEventNode的子类去重写_execute
	## 新建一个自定义的事件线程（不是真的线程，可以叫协程或者序列）来处理所有事件，并等待处理完成
	var et = EventThread.new()
	await et.trigger_event(event,trigger_self,args).on_complete
