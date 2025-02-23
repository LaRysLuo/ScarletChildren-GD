extends Node2D
class_name  GameState

const NORMAL = 0 # 正常状态
const BUSZING = 1 # 忙碌状态
const UIONLY = 2 #仅限UI



@export var _game_state: int:
    set(val):
        _game_state = val
        # print("gamestate游戏状态变化了：",val)
        on_game_state_changed.emit(val,is_buszing())



# 信号
signal  on_game_state_changed(val:int,is_buszing:bool)

func get_value():
    return _game_state

func is_buszing() -> bool:
    return _game_state == BUSZING

func is_uionly() -> bool:
    return _game_state == UIONLY

func is_normal() -> bool:
    return _game_state == NORMAL


func set_game_state_buszing():
    _game_state = BUSZING

func set_game_state_return(val:int):
    match val:
        0:
            set_game_state_normal()
        1:
            set_game_state_uionly()

func set_game_state_uionly():
    _game_state = UIONLY

func set_game_state_normal():
    _game_state = NORMAL


