extends Node
class_name GameData

## 这是游戏的数据管理类


var data_items = preload("res://auto_load/game_data/data_items/data_items.gd").new()


#region 外部调用

## 初始化
func initialize():
    data_items.load_items_raw()


## 载入数据
func make_item_by_loaded_data(loaded:SaveData):
    data_items.make_item_by_loaddata(loaded.items)

#endregion 