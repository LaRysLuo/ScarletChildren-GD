extends Node
class_name GameData

## 这是游戏的数据管理类


# var data_items = preload("res://auto_load/game_data/data_items/data_items.gd").new()
var data_sound:DataSound = preload("res://auto_load/game_data/data_audio/data_audio.gd").new()
var data_scene:DataScene = preload("res://auto_load/game_data/data_scene/data_scene.gd").new()

func _ready() -> void:
    self.add_child(data_sound)
    self.add_child(data_scene)

#region 外部调用

#endregion 

