extends Node


func _ready() -> void:
    _load_file()
    pass

func _load_file():
    var dat:Dictionary = Save.get_data_from_file("save2.dat")
    var game_player:Dictionary = dat.get("game_player")
    game_player["current_scene"] = "蔷薇馆·西馆走廊1F"
    dat["game_player"] = game_player

    print("读取到存档dat:",dat)
    var file = FileAccess.open("user://save2.dat", FileAccess.WRITE)
    file.store_var(dat,true)
    print("修改成功")