extends Node
# AUTO LOAD

## Scripts解释器
# WARNING 未完工 

## Dependence
# -  GameManager

var player:PlayerV1:
	get(): return GameManager.game_player.player

var interact_with:Event:
	get(): 
		if !player: return null
		return player.interact_with


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
func update_item(from:String,to:String) -> void:
	GameManager.game_player.update_item(from,to)

## 获得道具
func gain_item(to:String) ->void:
	GameManager.game_player.gain_item(to)

func play_se() -> void:
	# await 
	pass

func fadeout(time:float)-> void:
	await GameManager.fadeout_black(time)

func  fadein(time:float)-> void:
	await GameManager.fadein(time)



## CONDITION代码

func in_group(node:Node,group_name:String) -> bool:
	if !node: return false
	return node.is_in_group(group_name)

## 玩家是否获得过道具
func has_item(item_key:String,is_all:bool = false):
	return	GameManager.game_player.has_item(item_key,is_all)
	
func is_flash() -> bool:
	return GameManager.player.get_light_switch()

## 查看前方事件是否是对应事件
# event_name为Event.event_name的值
func with_event(event_name:StringName) -> bool:
	var with:Event = GameManager.player.interact_with
	if !with: return false
	return with.event_name == event_name




## void代码
func eval(code:String):
	var err = exps.parse(code,inputs.keys())
	if err != OK:
		printerr("解析出现错误了")
		return 
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