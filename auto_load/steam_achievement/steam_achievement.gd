extends Node
class_name SteamAchievement

var achievements:Dictionary = {
    "01_WELCOME_TO_SCARLETMANOR":false
}

## 表示从服务器同步过一次数据
var is_loaded_data_from_steam:bool = false

func load_all_achievenment_from_steam():
    for key in achievements.keys():
        get_achievement(key)
    print("[Steam]已经从服务器读取成就:%s" % achievements)
    is_loaded_data_from_steam = true

## 获取成就
func get_achievement(value:String)  -> void :
    var this_achievement:Dictionary = Steam.getAchievement(value)
    if this_achievement['ret']:
        if this_achievement['achieved']:
            achievements[value] = true
        else: achievements[value] = false
    else: achievements[value] = false

## 解锁成就
func unlock_achievement(value:String) ->void:
    # if !is_loaded_data_from_steam:
    #     push_error("还没有从Steam服务器同步成就数据")
    #     return
    if achievements.has(value):
        if not achievements[value]:
            achievements[value] = true
            Steam.setAchievement(value)
            Steam.storeStats()


func test_remove_achievement(value:String) -> void:
    Steam.clearAchievement(value)
    Steam.storeStats()

