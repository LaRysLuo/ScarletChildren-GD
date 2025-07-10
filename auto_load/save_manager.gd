extends Node2D
class_name Save

## SaveData 存档文件

## Config 用户配置类
## SaveData 存档数据类

## 存档文件的路径
const FILE_PATH = "user://save0.dat"

## 存档文件的数量
const FILE_COUNT = 5

## 可存储类的引用
static var _savable_list:Dictionary:
    get: return GameManager.savable_list


## 保存数据：并决定于保存到哪个存档位置
static func save_data(slot:int):
    ## 将数据存入到传入的槽位
    var file = FileAccess.open("user://save%s.dat" % slot , FileAccess.WRITE)
    file.store_var(mk_save_data(),true)
    print("[Save]存档成功")

## 获取存档数据
static func mk_save_data() -> Dictionary:
    var _data:Dictionary
    for key in _savable_list.keys():
        _data[key] = _savable_list.get(key).to_data()
    _data["create_time"] = get_current_time_string()
    return _data

## 获取当前时间
static func get_current_time_string() -> String:
    var now = Time.get_datetime_dict_from_system()
    return "%04d-%02d-%02d %02d:%02d:%02d" % [
        now.year, now.month, now.day,
        now.hour, now.minute, now.second
    ]

static  func data_count() -> int:
    return get_save_data_list().filter(func(item):return item != null).size()

## 获取存档的列表
static func get_save_data_list():
    var save_files = []
    for i in FILE_COUNT:
        var _file = get_data_from_file("save%s.dat" % i)
        save_files.append(_file) 
    return save_files
    
## 判断是否有存档
static func exist() -> bool:
    return get_save_data_list().any(func(i):return i != null)


## 转换存档信息
static  func get_save_data_info(_save_data:Dictionary,slot_id:int) -> SaveData:
    print("[Save]读取到存档信息:%s" % _save_data)
    var _game_player:Dictionary = _save_data.get("game_player")
    var _game_time:Dictionary = _save_data.get("game_time")
    return SaveData.new(
        _game_player.get("current_scene",""),
        _game_player.get("map_name",""),
        _game_player.get("player_pos",Vector2i.ZERO),
        _game_time.get("current_time",0),
        _save_data.get("create_time",""),
        slot_id
    )

##  载入数据: 读取硬盘中的存档文件夹
static func get_data_from_file(file_name:String):
    var file =  FileAccess.open("user://%s" % file_name,FileAccess.READ)
    # if not file: return
    # print("发现文件%s" % file)
    # var length := file.get_length()
    # var bytes: PackedByteArray = file.get_buffer(length)

    # print("文件大小: %d 字节" % length)
    # print("原始字节数据:")
    # print(bytes)  # 输出为类似 [8, 1, 160, 12, ...]
    if file: return file.get_var(true)

## 将游戏载入,将数据回归到游戏中  
static  func load_data(slot_id:int):
    var file_name = "save%s.dat" % slot_id
    var _data:Dictionary = get_data_from_file(file_name)
    for key in _data.keys():
        ## 通过key从
        if not _savable_list.has(key): continue
        var _game = _savable_list.get(key)
        await _game.from_data(_data.get(key))
    await  GameManager.game_player.resume_scene_and_player_pos()
    print("读档成功")