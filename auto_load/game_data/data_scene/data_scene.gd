extends Node
class_name DataScene


# =========================
# 常量记录场景路径记录名称
# =========================

## 第一章1节地图

## 蔷薇馆1F-厨房
const KITCHEN_1F = "蔷薇馆1F-厨房"
## 蔷薇馆1F-杂物间
const STORAGE_1F = "蔷薇馆1F-杂物间"
## 蔷薇馆·图书室1F          
const LIBRARY_1F = "蔷薇馆1F·图书室"
## 蔷薇馆·中厅1F
const ATRIUM_1F = "蔷薇馆·中厅1F"           
## 蔷薇馆·楼道间
const HALLWAY = "蔷薇馆·楼道间L"            
## 蔷薇馆·西馆走廊1F
const WEST_CORRIDOR_1F = "蔷薇馆·西馆走廊1F"    
 

## 第一章2节
## 蔷薇馆·1号房间
const ROOM_1 = "蔷薇馆·1号房间"
## 蔷薇馆·2号房间
const ROOM_2 = "蔷薇馆·2号房间"
## 蔷薇馆·3号房间
const ROOM_3 = "蔷薇馆·3号房间"
## 蔷薇馆·中厅2F
const ATRIUM_2F = "蔷薇馆·中厅2F"
## 蔷薇馆·浴室&卫生间2F
const BATHROOM_2F =  "蔷薇馆·浴室2F"
## 蔷薇馆·西馆走廊2F
const WEST_CORRIDOR_2F = "蔷薇馆·西馆走廊2F"
## 幽灵空间
const PHANTOM_SPACE_2F = "蔷薇馆·幽灵空间2F"

## 地图唯一id与场景地址的关联字典
const map_scene_config = {
	## 伊章

	## E01
	KITCHEN_1F: "res://scenes/maps/1伊章/蔷薇馆1F~厨房/厨房.tscn",
	STORAGE_1F:"res://scenes/maps/1伊章/蔷薇馆1F~杂物间/杂物间.tscn",
	LIBRARY_1F:"res://scenes/maps/1伊章/蔷薇馆.图书室1F/map_蔷薇馆.图书室1F.tscn",
	ATRIUM_1F:"res://scenes/maps/1伊章/蔷薇馆·中厅1F/map_蔷薇馆·中厅.tscn",
	ATRIUM_2F:"res://scenes/maps/1伊章/蔷薇馆·中厅2F/map_蔷薇馆·中厅2f.tscn",
	HALLWAY:"res://scenes/maps/1伊章/蔷薇馆·楼道间/map_蔷薇馆·西馆楼道间.tscn",
	WEST_CORRIDOR_1F:"res://scenes/maps/1伊章/蔷薇馆·西馆走廊1F/map_蔷薇馆·西馆走廊1f.tscn",
	
	## E02
	WEST_CORRIDOR_2F:"res://scenes/maps/1伊章/蔷薇馆·西馆走廊2F/map_蔷薇馆·西馆走廊2f.tscn",
	ROOM_1: "res://scenes/maps/2伊章/2蔷薇馆2F - 201室/Map_1号房间.tscn",
	ROOM_2:"res://scenes/maps/2伊章/2蔷薇馆2F - 202室/蔷薇馆2f - 2号房间.tscn",
	ROOM_3: "res://scenes/maps/2伊章/2蔷薇馆2F - 203室/Map_3号房间.tscn",
	PHANTOM_SPACE_2F: "res://scenes/maps/2伊章/2蔷薇馆2F - 幽灵空间/map_幽灵空间.tscn",
	BATHROOM_2F:"res://scenes/maps/2伊章/2蔷薇馆2F - 浴室/map_蔷薇馆2f-浴室.tscn",

	## E03

	## E04


}

## 储存地图唯一id和地图资源场景的关联字典
var _map_scene_raw:Dictionary

## 初始化回调
func _ready() -> void: pass
	# _load_all_scene() 

## 遍历map_scene_config载入所有的场景
func _load_all_scene():
	for scene_id in map_scene_config.keys():
		var scene_path:String = map_scene_config.get(scene_id)
		var scene = load(scene_path)
		if scene == null or not scene is PackedScene:
			push_error("加载失败或不是PackedScene: %s" % scene_path)
			continue
		if _map_scene_raw.has(scene_id):
			push_error("存在了同名的scene_id:%s" % scene_id)
			return
		_map_scene_raw[scene_id] = scene
	print("[DataScene]已载入所有地图场景")

## 获得场景
func get_scene(map_id:String) -> PackedScene:
	return _map_scene_raw.get(map_id)

## 获取场景路径
func get_scene_path(map_id:String) -> String:
	return map_scene_config.get(map_id)
