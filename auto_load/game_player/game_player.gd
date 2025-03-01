extends Node
class_name GamePlayer


var player_pre:Resource = preload("res://character/player.tscn") # 玩家预制体

## 玩家类
@export var player:PlayerV1:
	set(val):
		player = val
		on_player_loaded.emit()

## 这是玩家背包中的所有道具
#包含了已经使用完毕不显示的道具
@export var items:Array[Item] = []

## 获取背包中可展示的道具
@export var get_shown_items:Array[Item]:
	get(): return items.filter(func(item:Item): return !item.is_finished)


## 需要调用data_items或者game_data

var data_items:DataItems:
	get(): return GameManager.game_data.data_items


## SIGNAL 
## 当玩家的道具变化时 1表示获得 0表示失去 2表示更新
# 这个用于通知
signal on_player_item_changed(item_name:StringName,state:int)
signal on_bag_item_changed
signal on_player_loaded # 当玩家实例生成时



## 道具效果列表 OLD
#var item_effect = {
	### 装着永久相纸的拍立得
	#"02i_1_老式拍立得": func(_self:Item):
		#GameManager.set_game_state_buszing()
		### 判断条件是否可拍照
		#var interact_with =  GameManager.player.interact_with
		#if !interact_with  || !interact_with.is_in_group("save_point"):
			#DialogueManager.show_message("这里不能自拍",0,0)
			#GameManager.set_game_state_normal()
			#return
		#DialogueManager.show_message("你用的是永久相纸，要在这里自拍吗？",0,0)
		#await  DialogueManager.dialogue_typing_finish 
		##var d = Dictionary()
		#var options:Array[Dictionary] = [
			#{
				#"name":"确定",
				#"child_index":1
			#},
			#{
				#"name":"取消",
				#"child_index":0
			#}
		#]
		#DialogueManager.show_options(options)
		#
		#var result:int = await  DialogueManager.options_finish
		#if result == 1:
			### 获得拍照成功的相纸
			#GameManager.data_player.gain_item("03i_1_永久相纸")
			#GameManager.data_player.update_item(_self,"02i_0_老式拍立得")
			#SaveManager.save_data()
			#await  AudioManager.play_se("camera2")
			#DialogueManager.show_message("拍照成功了！",0,0)
		#else:
			#GameManager.player._init_player()
		#GameManager.set_game_state_normal(),
		#
	### 手电筒使用
	#"06i_0_手电筒（无电池）": func(_self:Item):
		#DialogueManager.show_message("flashlight01",0,0)
		#pass,
#}



## 合成列表
## 组合列表
var recipes:Dictionary = {
	## 在没有相纸的相机上组装永久相纸
	## 失去永久相纸
	## 失去没有相纸的相机
	## 获得装有永久相纸的相机
	["02i_0_老式拍立得","03i_0_永久相纸"]: func(craft_list): 
		remove_item(craft_list[1])
		update_item(craft_list[0],"02i_1_老式拍立得"),
	## 在没有相纸的相机上组装一次性相纸
	## 失去没有相纸的相机
	## 失去一次性相纸
	## 获得装有一次性相纸的相机
	["02i_0_老式拍立得","04i_一次性相纸"]:func(craft_list):
		remove_item(craft_list[1])
		update_item(craft_list[0],"02i_2_老式拍立得"),
	## 在有永久相纸的相机上组装一次性相纸
	## 	失去一次性相纸
	## 失去装有永久相纸的相机
	## 获得永久相纸
	## 获得装有一次性相纸的相机
	["02i_1_老式拍立得","04i_一次性相纸"]:func(craft_list):
		remove_item(craft_list[1])
		update_item(craft_list[0],"02i_2_老式拍立得")
		gain_item_array(["03i_0_永久相纸"]),
	["02i_2_老式拍立得","03i_0_永久相纸"]:func(craft_list):
		remove_item(craft_list[1])
		update_item(craft_list[0],"02i_1_老式拍立得")
		gain_item_array(["04i_一次性相纸"]),
	["06i_3_手电筒（魔法灯）","103i_0_5号电池"]:func(craft_list):
		remove_item(craft_list[1])
		update_item(craft_list[0],"06i_4_手电筒（魔法灯有电池）")
}

# 创建玩家
func instance_player(map:Node2D,vec:Vector2):
	if player: print_debug("初始化玩家错误，当前已生成玩家，请确认整个游戏玩家标识是否只有1个")
	if !player_pre: print_debug("初始化玩家失败，未设置玩家场景的路径")
	player = player_pre.instantiate() 
	player.position = vec
	# player.start_pos_changed.connect(update_fog)
	map.add_child(player)


## 是否能合成
func craft_enabled(key:Array[String]) -> bool:
	return recipes.has(key)

## 合成操作
func make_craft_call(key):
	recipes.get(key).call(key)


## 判断背包中是否存在指定道具
func has_item(item_id:StringName,is_finished:bool = false) -> bool:
	print("items=",items)
	var filters
	if !is_finished:
		filters = items.filter(func(item:Item): return item.item_id == item_id && item.is_finished == false)
	else:
		filters = items.filter(func(item:Item): return item.item_id == item_id)
	if filters.is_empty(): return false
	return true


## 初始化的时候载入道具
func load_items_at_start() -> void:
	pass
	#items.append(load(path + "/01c_迷之身影.tres"))
	#items.append(load(path + "/02i_0_老式拍立得.tres"))
	#items.append(load(path + "/03i_0_永久相纸.tres"))
	#items.append(load(path + "/04i_一次性相纸.tres"))



func use_item(item:Item):
	var event_res = data_items.get_use_callback(item)
	## 1.关掉道具窗口
	await  SceneManager.backall()
	## 2.触发物品效果
	print("触发物品效果")
	await  GameManager.trigger_event_res(event_res)


func usable(item:Item) ->bool:
	return data_items.get_use_callback(item) != null

## 触发物品效果 经常被
# 用于阅读资料等,first_read表示第一次读取
func trigger_item(item_key:StringName,first_read:bool):
	var item = data_items.get_item_in_raw_list(item_key)
	var event_res = data_items.get_use_callback(item)
	if !event_res:
		printerr("event_res没有配置")
		return
	await GameManager.trigger_event_res(event_res,null,{
		"close_any":!first_read
	})

## 移出物品 将物品隐藏
func remove_item(item_key:String,ingore_notify:bool = false) -> String:
	var item:Item = find_item(item_key)
	print("item_key=",item)
	if !item: return ""
	var item_name:String = str(item.item_name)
	item.is_finished = true
	if ingore_notify: return item_name
	on_player_item_changed.emit(item_name,0)
	on_bag_item_changed.emit()
	return item_name


## 找到物品
func find_item(item_key:String) -> Item:
	var filters = items.filter(func(item:Item):return item.item_id == item_key)
	if !filters.is_empty():
		return filters[0]
	return null

	
## 获得物品	
#GameManager.data_player.gain_item("201c_0_餐厅的八音盒")
func gain_item(item_key:String,ingore_notify:bool = false):
	var entity = data_items.get_item_in_raw_list(item_key)
	items.append(entity.duplicate())
	if !ingore_notify: on_player_item_changed.emit(entity.item_name,1)
	on_bag_item_changed.emit()

## 更新道具
# item_lose表示从背包里失去的道具
# item_gain_key表示获得到背包的道具
# GameManager.data_player.update_item("201c_0_餐厅的八音盒","201c_1_餐厅的八音盒")
func update_item(to_lose:String,to_gain:String) -> void:
	var item_name:String = remove_item(to_lose,true)
	gain_item_array([to_gain],true)
	on_player_item_changed.emit(item_name,2)
	on_bag_item_changed.emit()

func gain_item_array(item_key_list:Array[String],ingore_notify:bool = false):
	for item_key in item_key_list:
		gain_item(item_key,ingore_notify)

	
