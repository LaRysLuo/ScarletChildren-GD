extends Node
class_name GameItems

## 这是玩家背包中的所有道具
#包含了已经使用完毕不显示的道具
@export var items:Array[Item] = []

## 获取背包中可展示的道具
@export var get_shown_items:Array[Item]:
	get(): return items.filter(func(item:Item): return !item.is_finished)


## 需要调用data_items或者game_data
var data_items:DataItems = preload("res://auto_load/game_data/data_items/data_items.gd").new()


## 合成列表:组合列表
var _recipes:Dictionary = {
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

#region SIGNAL 
## 当玩家的道具变化时 1表示获得 0表示失去 2表示更新
# 这个用于通知
signal on_player_item_changed(item_name:StringName,state:int)
signal on_bag_item_changed

#endregion 


#region 外部调用
func initialize() -> void:
	data_items.load_items_raw()

func get_items_catagory(catagory_type:int) -> Array[Item]:
	return items.filter(func(item:Item): return !item.is_finished && item.item_catagory == catagory_type )

#endregion


## 是否能合成
func craft_enabled(key:Array[String]) -> bool:
	return _recipes.has(key)

## 合成操作
func make_craft_call(key):
	_recipes.get(key).call(key)


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

# 只有在测试模式会生效，会在读取存档后额外加入这些东西
func load_items_at_start() -> void:
	# items.append(load("res://event_res/item_res/104i_手机.tres"))
	pass
	#items.append(load(path + "/01c_迷之身影.tres"))
	#items.append(load(path + "/02i_0_老式拍立得.tres"))
	#items.append(load(path + "/03i_0_永久相纸.tres"))
	#items.append(load(path + "/04i_一次性相纸.tres"))



func use_item(item:Item):
	var event_res = data_items.get_use_callback(item)
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
	var item:Item = _find_item(item_key)
	print("item_key=",item)
	if !item: return ""
	var item_name:String = str(item.item_name)
	item.is_finished = true
	if ingore_notify: return item_name
	on_player_item_changed.emit(item_name,0)
	on_bag_item_changed.emit()
	return item_name


## 找到物品
func _find_item(item_key:String) -> Item:
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
func update_item(to_lose:String,to_gain:String,ingore_notify:bool = false) -> void:
	var item_name:String = remove_item(to_lose,true)
	gain_item_array([to_gain],true)
	if not ingore_notify:on_player_item_changed.emit(item_name,2)
	on_bag_item_changed.emit()

func gain_item_array(item_key_list:Array[String],ingore_notify:bool = false):
	for item_key in item_key_list:
		gain_item(item_key,ingore_notify)

	
func to_data() -> Dictionary:
	return {
		"items": items
	}

func from_data(_data:Dictionary) -> void:
	print("[GameItems]游戏道具类被重新载入")
	var _items = _data.get("items")
	for item in _items.map(func(x): return x as Item):
		items.append(item) 
	
	if OS.is_debug_build():
		load_items_at_start()
		print("[TEST]测试模式成功导入道具:",items)
	# for item in _items:
	#     print("[Item]这个item是%s" % item.item_id)
	#     items.append(item) 
