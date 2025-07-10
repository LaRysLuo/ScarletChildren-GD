extends Node2D
class_name TutorialNode

var map_chunks:Maps:
    get: return get_parent().get_node("Maps")

# 获取到几个特殊节点
@export var tutorial_res:Array[TutorialData]

## 让一个幽灵出现在对应的方向
var DIRS = {
    3: Vector2(413,69), # UP
    1: Vector2(101,303), # LEFT
    2: Vector2(738,303), # RIGHT
    0: Vector2(413,716) # DOWN
}

const phantom_res = preload("res://scenes/maps/0序章/迷途森林/prefabs/phantom.tscn") 


var ui_grid:Node:
    get: return get_parent().get_node("UI")

var fog:TwoDFog:
    get: return ui_grid.get_node("2DFog")

var tutorial_index:int = -1

## 当前教程节点
var current_tutorial:TutorialData:
    get: return tutorial_res[tutorial_index]

func _ready() -> void:
    if !GameManager.player: await GameManager.on_player_loaded
    map_chunks.chunk_changed.connect(_chunk_changed)
    # map_chunks.chunk_init.connect(_new_chunk_init)
    # call_deferred("_next")
    _next()
    

## 当跨过地图边界时
func _chunk_changed(from:Vector2i,to:Vector2i,chunk_size:int):
    var dir:Vector2i = to - from
    current_tutorial.valid_finish(dir)

    ## 新的场景显示
    show_phantom(to,chunk_size)

var phantom_list:Array[Node2D]
func show_phantom(target_pos:Vector2i,chunk_size:int): 
    clear_phantom()
    ## 如果是随机目标节点
    if current_tutorial.get_dir_vector() == Vector2i.ZERO:
        ## 显示人影
        var dir_range = current_tutorial.get_current_phantom_vec()
        for dir_index in dir_range:
            var phantom = phantom_res.instantiate()
            add_child(phantom)
            phantom.position = DIRS[dir_index] + Vector2(target_pos * chunk_size)
            phantom.frame =  dir_index
            phantom_list.append(phantom)

func clear_phantom():
    for phantom in phantom_list:
        phantom_list.erase(phantom)
        phantom.get_parent().remove_child(phantom)
        phantom.queue_free()

## 下一个教程节点
func _next():
    tutorial_index += 1
    # Tutorial.hide_message()
    
    print("[Test]1111")
    await current_tutorial.trigger()
    print("[TEST]2222")
    await  update_flog_density()
    Tutorial.show_message(current_tutorial.tutorial_id,ui_grid)
    
    # print("[Tutorial]第一个节点运行完毕")
    await _extend_maps()
    await current_tutorial.finished
    Tutorial.hide_message()
    if tutorial_index  < tutorial_res.size() - 1: _next()

## 更新雾气浓度
func update_flog_density():
    var target_fog_density = current_tutorial.fog_change_count
    if target_fog_density == -1:
        return
    var tween
    GameManager._event_trigger_start()
    # fog.fog_density ## 设置一个计时器，使fog.fog_density数值变化到target_fog_density
     # 如果没有 tween 节点就创建一个
    tween = create_tween()
    # tween.name = "FogTween"
    # fog.add_child(tween)

    # 使用 Tween 插值 fog_density
    tween.tween_property(fog, "fog_density", target_fog_density, 1.0)
    tween.play()
    await tween.finished
    GameManager._event_trigger_end()

## 扩展边界
func _extend_maps():
    if !current_tutorial.extend_map: return
    print("[Tutorial]地图开始扩展")
    map_chunks.map_extend()
