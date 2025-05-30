extends Node

const APP_ID = 3770050 # 蔷薇之子的APPID
 
func _ready() -> void:
    _init_steam()

func _process(_delta: float) -> void:
    Steam.run_callbacks()

func _init_steam():
    var init_resp:Dictionary = Steam.steamInitEx(APP_ID)
    Steam.current_stats_received.connect(_current_stats_received)
    Steam.user_stats_received.connect(_user_stats_received)


func _current_stats_received(_game_id: int, _result: int, _user_id: int):
    
    pass

func _user_stats_received(_game_id: int, _result: int, _user_id: int):
    pass