extends Node
class_name GamePlayer

## 玩家的预制体
var player_pre:Resource = preload("res://character/player.tscn") # 玩家预制体

## 玩家类
@export var player:PlayerV1:
    set(val):
        player = val
        call_deferred("do_player_loaded")

const player_ability_raw = [
    "running",
]

## 玩家能力
var player_ability:Array[String]:
    set(val):
        player_ability = val
        _update_all_ability()
        
#region 信号
signal on_player_loaded # 当玩家实例生成时

#endregion


func _update_all_ability():
    if !player: 
        await on_player_loaded
    player._ability = player_ability

## 发射<玩家载入完成>信号
func do_player_loaded():
    on_player_loaded.emit()

## 获得角色能力，包括以下几种，奔跑能力，打开菜单能力等等
func gain_ability(ability_name:String,enable:bool):
    if enable && !player_ability.has(ability_name):
        player_ability.append(ability_name)
        print("[PlayerAbility]玩家的能力变化了：%s" % player_ability)
        player.update_ability(player_ability)
    else:
        if player_ability.has(ability_name):
            player_ability.erase(ability_name)
            print("[PlayerAbility]玩家的能力变化了：%s" % player_ability)
            player.update_ability(player_ability)

# 创建玩家
func instance_player(map:Node2D,vec:Vector2):
    if player: print_debug("初始化玩家错误，当前已生成玩家，请确认整个游戏玩家标识是否只有1个")
    if !player_pre: print_debug("初始化玩家失败，未设置玩家场景的路径")
    player = player_pre.instantiate() 
    player.position = vec
    # player.start_pos_changed.connect(update_fog)
    map.add_child(player)

func instance_player_with_vector2i():
    pass

## 转为存档数据
func to_data(): 
    return {
        "current_scene": SceneManager.current_map,
        "map_name":SceneManager.current_map_name,
        "player_pos": player.cell_pos,## 玩家坐标
        "player_ability":player_ability ## 玩家能力
    }

var to_moved_info:Dictionary = {}

func from_data(_data:Dictionary) -> void:
    player_ability = _data.get("player_ability")
    to_moved_info = {
        "loaded_scene":  _data.get("current_scene"),
        "loaded_pos": _data.get("player_pos")
    }


    # print("读取的坐标是%s:" % _loaded_pos)
    # await  _resume_scene_and_player_pos(_loaded_scene,_loaded_pos)

func resume_scene_and_player_pos():
    if to_moved_info.is_empty():return
    ## 将场景移动到
    print("开始淡出画面")
    await  Interpreter.fadeout(0.5)
    await  SceneManager.move(to_moved_info.get("loaded_scene"),to_moved_info.get("loaded_pos"),false,true)
    await  Interpreter.fadein(1)
    to_moved_info = {}
