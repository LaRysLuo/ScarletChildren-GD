extends Node
class_name DataPlayer

## 这是玩家背包中的所有道具
#包含了已经使用完毕不显示的道具
@export var items:Array[Item]

## 获取背包中可展示的道具
@export var get_shown_items:Array[Item]:
	get(): return items.filter(func(item:Item): return !item.is_finished)



var items_raw:Array[Item]

## SIGNAL 
## 当玩家的道具变化时 1表示获得 0表示失去 2表示更新
# 这个用于通知
signal on_player_item_changed(item_name:StringName,state:int)
signal on_bag_item_changed


const path = "res://event_res/item_res"

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

## 道具效果列表新 NEW
# KEY为ItemID
# VALUE为EventRes
var item_effect_config = {
	"02i_1_老式拍立得": "res://event_res/item_res/effect/02i_1_老式拍立得.tres",
	"02i_2_老式拍立得": "res://event_res/item_res/effect/02i_1_老式拍立得.tres",
	"06i_0_手电筒（疑问）":"res://event_res/item_res/effect/06i_0_手电筒（疑问）.tres",
	"07f_蔷薇馆的传闻":"res://event_res/item_res/effect/07f_蔷薇馆的传闻.tres",
	"06i_2_手电筒（有电池）":"res://event_res/item_res/effect/06i_2_手电筒（有电池）.tres",
}

## 合成列表
## 组合列表
var recipes:Dictionary = {
	## 在没有相纸的相机上组装永久相纸
	## 失去永久相纸
	## 失去没有相纸的相机
	## 获得装有永久相纸的相机
	["02i_0_老式拍立得","03i_0_永久相纸"]: func(craft_list): 
		complete_item(craft_list[1])
		update_item(craft_list[0],"02i_1_老式拍立得"),
	## 在没有相纸的相机上组装一次性相纸
	## 失去没有相纸的相机
	## 失去一次性相纸
	## 获得装有一次性相纸的相机
	["02i_0_老式拍立得","04i_一次性相纸"]:func(craft_list):
		complete_item(craft_list[1])
		update_item(craft_list[0],"02i_2_老式拍立得"),
	## 在有永久相纸的相机上组装一次性相纸
	## 	失去一次性相纸
	## 失去装有永久相纸的相机
	## 获得永久相纸
	## 获得装有一次性相纸的相机
	["02i_1_老式拍立得","04i_一次性相纸"]:func(craft_list):
		complete_item(craft_list[1])
		update_item(craft_list[0],"02i_2_老式拍立得")
		gain_item_array(["03i_0_永久相纸"]),
	["02i_2_老式拍立得","03i_0_永久相纸"]:func(craft_list):
		complete_item(craft_list[1])
		update_item(craft_list[0],"02i_1_老式拍立得")
		gain_item_array(["04i_一次性相纸"]),
	["06i_3_手电筒（魔法灯）","103i_0_5号电池"]:func(craft_list):
		complete_item(craft_list[1])
		update_item(craft_list[0],"06i_4_手电筒（魔法灯有电池）")
}


## 判断背包中是否存在指定道具
func has_item(item_id:StringName,is_finished:bool = false) -> bool:
	var filters
	if !is_finished:
		filters = items.filter(func(item:Item): return item.item_id == item_id && item.is_finished == false)
	else:
		filters = items.filter(func(item:Item): return item.item_id == item_id)
	if filters.is_empty(): return false
	return true
	
	
	

func load_items() -> void:
	items.append(load(path + "/01c_迷之身影.tres"))
	items.append(load(path + "/02i_0_老式拍立得.tres"))
	items.append(load(path + "/03i_0_永久相纸.tres"))
	items.append(load(path + "/04i_一次性相纸.tres"))

## 载入所有道具
# 并将物品的使用效果赋予
func load_items_raw():
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				var item:Item = load(path+"/" + file_name) as Item
				#var callback = item_effect.get(item.item_id)
				#print("道具%s的callback=%s",[item.item_name,callback])
				var callback_new = item_effect_config.get(item.item_id)
				#if callback: 
					#item.use_event = callback
				if callback_new: 
					item.use_event_new = load(callback_new)
				## TODO 当前在将旧的Callback更换成新的EventRes
				items_raw.append(item) 
			file_name = dir.get_next()
		dir.list_dir_end()
	else: print("没有该目录")

## 生成新的道具栏
func make_item_by_loaddata(loaded_items:Array[Item]):
	var new_items:Array[Item]
	for item:Item in loaded_items:
		var new_item =  find_item_from_raw(item.item_id)
		if !new_item: continue
		#print("new_item",new_item.is_finished)
		if item.is_finished:new_item.is_finished = item.is_finished
		else: new_item.is_finished = false
		new_items.append(new_item)
	self.items = new_items
	

## 获得该道具的callback
## INFO TODO 更新25.01.12
# 找出物品，并将使用效果返回
# 物品的使用效果使在物品在初始化的时候被赋予的
# 这里原本是回调函数，但现在改为EventRes
func get_use_callback(item:Item):
	var filters = items_raw.filter(func(itemx:Item):
		return itemx.item_id == item.item_id
		)
	if filters.is_empty(): return null
	var filter_item:Item = filters[0]
	return filter_item.use_event_new #已改为EventRes

## 触发物品效果
func trigger_item(item_key:StringName,first_read:bool):
	var item = find_item_from_raw(item_key)
	var event_res = self.get_use_callback(item)
	if !event_res:
		printerr("event_res没有配置")
		return
	await GameManager.trigger_event_res(event_res,null,{
		"close_any":!first_read
	})

## 移出物品 将物品隐藏
func complete_item(item_key:String,ingore_notify:bool = false) -> String:
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

func find_item_from_raw(item_key:String) ->Item:
	var filters = items_raw.filter(func(item:Item):return item.item_id == item_key)
	if !filters.is_empty():
		return filters[0]
	return null

	
## WARNING 已弃用
func remove_item_array(items:Array[Item]):
	pass
	#for item in items:
		#remove_item(item)
	
## 获得物品	
#GameManager.data_player.gain_item("201c_0_餐厅的八音盒")
func gain_item(item_key:String,ingore_notify:bool = false):
	var entity = get_item_in_raw_list(item_key)
	items.append(entity.duplicate())
	if !ingore_notify: on_player_item_changed.emit(entity.item_name,1)
	on_bag_item_changed.emit()

## 更新道具
# item_lose表示从背包里失去的道具
# item_gain_key表示获得到背包的道具
# GameManager.data_player.update_item("201c_0_餐厅的八音盒","201c_1_餐厅的八音盒")
func update_item(to_lose:String,to_gain:String):
	var item_name:String = complete_item(to_lose,true)
	gain_item_array([to_gain],true)
	on_player_item_changed.emit(item_name,2)
	on_bag_item_changed.emit()

func gain_item_array(item_key_list:Array[String],ingore_notify:bool = false):
	var item_list:Array[Item]
	for item_key in item_key_list:
		gain_item(item_key,ingore_notify)

func get_item_in_raw_list(key:String) -> Item:
	var item_entitys = items_raw.filter(func(item:Item): return item.item_id == key)
	var entity:Item
	if !item_entitys.is_empty():
		entity = item_entitys[0]
	else:
		printerr("出错了，无效的item_key:%s" % key)
	return entity
	
