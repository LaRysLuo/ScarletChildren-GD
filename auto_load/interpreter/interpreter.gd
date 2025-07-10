extends Node
# AUTO LOAD

## Scripts解释器


## 想要做一个特殊事件的管理器，

## Dependence
# -  GameManager

var player:PlayerV1:
	get(): return GameManager.game_player.player

var interact_with:Event:
	get(): 
		if !player: return null
		return player.interact_with
	
var trigger_event:Event

var current_ui:Node:
	get: return get_tree().current_scene.get_node("UI")


## 解释器本体
@onready var exps:Expression = Expression.new()
var inputs:Dictionary = {
	"player" =  player,
	"interObj" = interact_with,
	"gm" = GameManager,
	"am" = AudioManager
}


## 适用于VOID代码

## 更新道具
func update_item(from:String,to:String,ingore_notify:bool = false) -> void:
	GameManager.game_items.update_item(from,to,ingore_notify)

## 获得道具
func gain_item(to:String,ingore_notify = false) ->void:
	GameManager.game_items.gain_item(to,ingore_notify)
	
func remove_item(to:String) ->void:
	GameManager.game_items.remove_item(to)

## [使用V2声音管理器]播放音乐
func play_music(music_name:String):
	## 去声音数据中寻找匹配的声音资源
	var _audio  = GameManager.game_data.data_sound.get_sound(music_name)
	AudioManagerV2.play_music(_audio)


func play_se(audio_name:String,is_wait:bool = false,_vol:int = 0) -> void:
	var _audio = GameManager.game_data.data_sound.get_sound(audio_name)
	await AudioManagerV2.play_sfx(_audio,is_wait,_vol)

## 解锁成就
func unlock_achievement(key:String):
	GameManager.steam_achievement.unlock_achievement(key)

## 使事件无视碰撞
func set_event_ingore_collsion(event_name:String,ingore_collsion:bool = true):
	var result:Event = GameManager.parse_event_name(event_name) if event_name != "self" else trigger_event 
	if result: result.ingore_collsion = ingore_collsion

## 设置事件可见或者不可见
func set_event_visiable(event_name:String,visiable:bool): 
	var result:Event = GameManager.parse_event_name(event_name)
	result.visible = visiable

## 添加故事进度 -> 弃用
func add_story_flag(story_flag_name:String):
	GameManager.game_story.add_flag(story_flag_name)

## 设置变量
func set_variable(_name:String):
	GameManager.game_variable.set_variable(_name,true)


## 显示气泡表情
## 显示表情:self表示player玩家，其他玩家时
func show_balloon(char_name:String,balloon_name:StringName):
	var result:CharacterBase
	result =  GameManager.parse_event_name(char_name)
	if !result: 
		printerr("出错了:%s" % "事件名不能为空")
		return
	result.play_balloon(balloon_name)

## 隐藏气泡表情
func hide_balloon(): pass

## 隐藏全部气泡表情
func hide_all_balloon():pass

## 相机移动
func camera_move(offset:Vector2,time:float):
	await Camera.camera_move(offset,time)

func reset_camera(with_fade:bool = true):
	Camera.reset_camera(with_fade)
	pass

## 显示cg
func show_cg(file_path:String):
	SceneManager.show_cg(file_path)

# ## 隐藏cg
func hide_cg():
	SceneManager.hide_cg()

## 显示cg - v2
func show_cg_v2(file_path:String):
	CGShowToolV2.show_cg(file_path)

func hide_cg_v2():
	CGShowToolV2.hide_cg()

func save_game():
	## 存档游戏
	var slot = Save.data_count()
	Save.save_data(slot)
	var scene:SceneLoad = await  UIManager.show_ui("scene_load")
	scene.show_with_readonly(slot)


## 解锁玩家能力
func gain_player_ability(ability_name:String,enable:bool): 
	GameManager.game_player.gain_ability(ability_name,enable)

func show_tutorial(msg:String) -> void:
	Tutorial.show_message(msg,current_ui)

func fadeout(time:float)-> void:
	await GameManager.fadeout_black(time)

func fadein(time:float)-> void:
	await GameManager.fadein(time)
	



## CONDITION代码

func in_group(node:Node,group_name:String) -> bool:
	if !node: return false
	return node.is_in_group(group_name)

## 玩家是否获得过道具
func has_item(item_key:String,is_all:bool = false):
	return	GameManager.game_items.has_item(item_key,is_all)
	
## 查看前方事件是否是对应事件
# event_name为Event.event_name的值
func with_event(event_name:StringName) -> bool:
	var with:Event = GameManager.game_player.player.interact_with
	if !with: return false
	return with.event_name == event_name

func can_save() -> bool:
	print("data_count",Save.data_count())
	return Save.data_count() < Save.FILE_COUNT


## void代码
func eval(code:String,event):
	var err = exps.parse(code,inputs.keys())
	if err != OK:
		printerr("解析出现错误了")
		return 
	trigger_event = event
	var	result = exps.execute(inputs.values(),self)
	if exps.has_execute_failed():
		print("执行出错了:",exps.get_error_text())
		return
	return await result


## 条件处理
func condition_eval(code:String):
	var error = exps.parse(code,inputs.keys())
	if error !=OK:
		printerr("解析出现错误了")
		return
	var result = exps.execute(inputs.values(),self)
	if exps.has_execute_failed():
		print("执行出错了:",exps.get_error_text())
		return
	if  typeof(result) != TYPE_BOOL:
		print("返回的参数必须是布尔值")
		return
	return result
