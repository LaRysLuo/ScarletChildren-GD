@tool
extends Resource
class_name TutorialData

@export var tutorial_id:String: 
    set(val):
        tutorial_id = val
        tutorial_msg_preview = tr(tutorial_id)

@export var tutorial_msg_preview:String
@export var event_res:Events_Res #
@export_enum("UP", "RIGHT", "DOWN", "LEFT","RANDOM") var dir: String

func get_dir_vector() -> Vector2i:
    match dir:
        "UP": return Vector2i(0, -1)
        "RIGHT": return Vector2i(1, 0)
        "DOWN": return Vector2i(0, 1)
        "LEFT": return Vector2i(-1, 0)
        _: return Vector2i.ZERO

## 需要跑步才能触发，为了执行按shift跑步的教程，
@export var need_run_count:int
@export var taget_count:int # 移动场数

@export var fog_change_count:float = -1 # 雾浓度变化
@export var extend_map:bool = false # 在此节点触发时，会主动扩展边界



signal finished # 这个节点完成了

var enable:bool = false
var current_pos:Vector2i # 当前场景位置
var count:int 

var player_running:float

## 触发该事件
func trigger():
    if event_res: await GameManager.trigger_event_res(event_res)
    ## 如果需要跑步才能触发，那该节点订阅
    if need_run_count > 0:
        print("[TutorialData]需要等待跑步任务完成",need_run_count) 
        GameManager.player.on_stamina_used.connect(_player_run)
    else: 
        print("[TutorialData]等待任务完成")
        enable = true


## 当玩家跑过路程
func _player_run(val:float):
    player_running += val
    if player_running >= need_run_count: 
        enable = true
        print("[TutorialData]跑步任务完成了")
        GameManager.player.on_stamina_used.disconnect(_player_run)
        # do_finished()


## 校验是否达成
func valid_finish(_dir:Vector2i):
    if !enable: return
    if taget_count <= 0 :return ## 如果目标数量是-1不触发该时间
    ## 随机模式：每次进入该模式会随机生成5个方向
    if get_dir_vector() == Vector2i.ZERO: 
        if ROUTE[_lost_clear_index] == _dir:
            _lost_clear_index += 1 # 进度+1
            if _lost_clear_index >= 5:
                do_finished()
        else: _lost()
           
    else:
        if get_dir_vector() == _dir:
            count += 1
            if taget_count == count:
                do_finished()
        else: count = 0

## 使该节点完成
func do_finished():
    finished.emit()



# 随机生成1条路线
const ALLMAP = [
    Vector2i(0,0), # 下右
    Vector2i(1,0), # 下中
    Vector2(2,0),  # 下左
    Vector2i(0,1), # 中右
    Vector2(2,1),  # 中左 
    Vector2(0,2),  # 上右
    Vector2(1,2),  # 上中
    Vector2(2,2),   # 上左
    Vector2i(1,1), # 中中：固定是迷雾，在其他八个区域会随机选择一个出生点
]
var ROUTE = [
    Vector2i.LEFT,
    Vector2i.UP,
    Vector2i.UP,
    Vector2i.RIGHT,
    Vector2i.UP
]

var PHANTOM_VECTOR = [
    [1],
    [3],
    [3,2],
    [2,0],
    [3,0]
]

func get_current_phantom_vec():
    return PHANTOM_VECTOR[_lost_clear_index]


var _lost_clear_index = 0

## 开始迷失游戏：在地图上
func start_lost(): 

    pass
const lost_event_res = preload("res://scenes/maps/0序章/迷途森林/lost_event.tres")
## 迷失方向，重置计数
func _lost():
    await GameManager.trigger_event_res(lost_event_res)
    _lost_clear_index = 0
