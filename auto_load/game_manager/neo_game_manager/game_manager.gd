## 这是新的游戏控制器
extends Node2D


## 引用模块节点
# var scene_manager: SceneManagerV2:
@onready var game_screen: GameScreen = $GameScreen
@onready var audio_manager: AudioManager= $AudioManager

## 引用模块脚本
var game_player:GamePlayer = preload("res://auto_load/game_player/game_player.gd").new()
var game_state:GameState = preload("res://auto_load/game_state/game_state.gd").new()
var game_event:GameEvent = preload("res://auto_load/game_event/game_event.gd").new()
var game_time:GameTime = preload("res://auto_load/game_time/game_time.gd").new()
# var audio_manager:AudioManager = preload("res://auto_load/game_audio/audio_manager.gd").new()

func _ready() -> void:
	_init_audio_manager()
	_init_game_player()
	_init_game_event()
	_init_game_screen()
	_init_game_time()
	_init_scene_manager()


func _start() -> void:
	pass

## 初始化音频管理器
func _init_audio_manager():
	AudioManager.set_on_created(func(): return audio_manager)

## 初始化场景管理器
func _init_scene_manager(): 
	# 当进入新地图场景时，寻找周围是否有玩家初始化的点
	SceneManager.on_enter_map_scene.connect(game_player.find_player_and_instantiate)
	SceneManager.on_enter_map_scene.connect(game_event.init_all_event)
	SceneManager.on_scene_change_start.connect(game_state.set_game_state_buszing)
	SceneManager.on_scene_change_end.connect(game_state.set_game_state_return)
	SceneManager.call_deferred("_ready")
	## TODO 将画面增加淡出淡入效果
	SceneManager.set_effect(game_screen.fadein,game_screen.fadeout)

## 初始化游戏玩家管理器
func _init_game_player():
	# 当玩家初始化时，自动设置玩家到场景管理器中
	game_player.on_player_loaded.connect(SceneManager.set_player)
	# 当玩家初始化成功时，断开检查玩家的信号
	game_player.on_player_loaded.connect(_on_player_loaded)
	game_player.name = "GamePlayer"
	add_child(game_player)

## 初始化游戏状态管理器
func _init_game_state():
	## 信号连接：同步游戏状态的变化
	game_state.on_game_state_changed.connect(game_event.update_game_state)
	# game_state.on_game_state_changed.connect(scene_manager.update_game_state)


## 初始化游戏事件管理器
func _init_game_event():
	game_event.on_event_trigger_start.connect(game_state.set_game_state_buszing)
	game_event.on_event_trigger_start.connect(game_player.update_event_trigger_start)
	game_event.on_event_trigger_end.connect(game_state.set_game_state_normal)
	game_event.on_event_trigger_end.connect(game_player.update_event_trigger_end)
	game_event.on_event_play_se.connect(audio_manager.play_se)
	game_event.name = "GameEvent"
	add_child(game_event)

## 初始化游戏屏幕
func _init_game_screen():
	pass

func _init_game_time():
	game_time.name = "GameTime"
	add_child(game_time)
	pass

## 当玩家角色初始化完成时
func _on_player_loaded(player: PlayerV1):
	print("玩家初始化完成")
	# scene_manager.on_enter_map_scene.disconnect(game_player.find_player_and_instantiate)
	player.on_main_scene_call.connect(_open_main_scene)
	game_state.on_game_state_changed.connect(player.game_state_update)


## 打开主场景
func _open_main_scene():
	SceneManager.navigate_to("scene_main_menu")
