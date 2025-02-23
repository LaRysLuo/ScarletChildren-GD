extends Node
class_name GamePlayer

## 导出属性
@export var player:PlayerV1:
	set(val):
		player = val
		on_player_loaded.emit(player)

## 这是玩家背包中的所有道具
#包含了已经使用完毕不显示的道具
@export var items:Array[Item] = []

## 获取背包中可展示的道具
@export var get_shown_items:Array[Item]:
	get(): return items.filter(func(item:Item): return !item.is_finished)

var player_prefab:Resource = preload("res://entities/character/player.tscn")  # 玩家预制体

## 信号
signal on_player_loaded
# signal on_game_state_update # 当游戏状态变化时


## 寻找并实例化玩家
func find_player_and_instantiate():
	print("进入新场景了，现在开始搜索初始点")
	await get_tree().create_timer(0.1).timeout
	var playersignList = get_tree().get_nodes_in_group("player_sign")
	print("playersignList:", playersignList)
	if !playersignList: return null # 没找到玩家初始化标识返回
	if playersignList.size() > 1: print_debug("错误的开始点数量，开始点不能超过1个")
	var playersign = playersignList[0]
	if !player: _instance_player(playersign.get_parent(),playersign.global_position)
	playersign.queue_free() # 清除开始点


#region 信号回调函数

## 实例化玩家角色 / 回调函数
func _instance_player(map:Node2D,vec:Vector2):
	if player: print_debug("初始化玩家错误，当前已生成玩家，请确认整个游戏玩家标识是否只有1个")
	if !player_prefab: print_debug("初始化玩家失败，未设置玩家场景的路径")
	player = player_prefab.instantiate() 
	player.position = vec
	# player.start_pos_changed.connect(update_fog)
	map.add_child(player)
	# 初始化完毕，使游戏开始运行
	# set_game_state_normal()

## 更新事件开始
func update_event_trigger_start():
	player._event_trigger_start()

## 更新事件结束

func update_event_trigger_end():
	player._event_trigger_end()


#endregion 信号回调函数


## 判断背包中是否存在指定道具
func has_item(item_id:StringName,is_finished:bool = false) -> bool:
	var filters
	if !is_finished:
		filters = items.filter(func(item:Item): return item.item_id == item_id && item.is_finished == false)
	else:
		filters = items.filter(func(item:Item): return item.item_id == item_id)
	if filters.is_empty(): return false
	return true
