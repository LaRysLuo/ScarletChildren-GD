extends Node
class_name DataItems

const PATH = "res://event_res/item_res"


## 道具效果列表新 NEW
# KEY为ItemID
# VALUE为EventRes
const ITEM_EFFECT_CONFIG = {
	"02i_1_老式拍立得": "res://event_res/item_res/effect/02i_1_老式拍立得.tres",
	"02i_2_老式拍立得": "res://event_res/item_res/effect/02i_1_老式拍立得.tres",
	"06i_0_手电筒（疑问）":"res://event_res/item_res/effect/06i_0_手电筒（疑问）.tres",
	"07f_蔷薇馆的传闻":"res://event_res/item_res/effect/07f_蔷薇馆的传闻.tres",
	"06i_2_手电筒（有电池）":"res://event_res/item_res/effect/06i_2_手电筒（有电池）.tres",
}




## 这是道具的数据类，应该要拿回到data_item
@export var items_raw:Array[Item]

## 从本地文件系统中读取所有道具
func load_items_raw():
	var dir = DirAccess.open(PATH)
	if dir:
		print("目录为:",dir)
		dir.list_dir_begin()
		var file_name = dir.get_next()
		if !OS.is_debug_build():
			file_name = file_name.get_basename()
		print("文件名:",file_name)
		while file_name != "":
			## 忽略掉文件开头带#的物品资源
			if !dir.current_is_dir() and !file_name.begins_with("#"):
				var item:Item = load(PATH+"/" + file_name )
				print("文件名:",file_name)
				var callback_new = ITEM_EFFECT_CONFIG.get(item.item_id)
				if callback_new: 
					item.use_event_new = load(callback_new)
				## TODO 当前在将旧的Callback更换成新的EventRes
				items_raw.append(item) 
			file_name = dir.get_next()
			if !OS.is_debug_build():
				file_name = file_name.get_basename()
		dir.list_dir_end()
	else: print("没有该目录")

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


## 生成新的道具
# 读取存档时调用
func make_item_by_loaddata(loaded_items:Array[Item]):
	var new_items:Array[Item]
	for item:Item in loaded_items:
		var new_item =  get_item_in_raw_list(item.item_id)
		if !new_item: continue
		#print("new_item",new_item.is_finished)
		if item.is_finished:new_item.is_finished = item.is_finished
		else: new_item.is_finished = false
		new_items.append(new_item)
	self.items = new_items

## 找到某个key的道具1
# func find_item_from_raw(item_key:String) ->Item:
# 	var filters = items_raw.filter(func(item:Item):return item.item_id == item_key)
# 	if !filters.is_empty():
# 		return filters[0]
# 	return null

## 找到某个key的道具2 TODO 可以去除一个
func get_item_in_raw_list(key:String) -> Item:
	var item_entitys = items_raw.filter(func(item:Item): return item.item_id == key)
	var entity:Item
	if !item_entitys.is_empty():
		entity = item_entitys[0]
	else:
		printerr("出错了，无效的item_key:%s" % key)
	return entity
