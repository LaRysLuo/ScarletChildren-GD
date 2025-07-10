extends Node
class_name StoryFlagHandler

const PATH = "res://event_res/story_flag_res/"

@export var story_flag_raw:Array[StoryFlag]
@export var story_flag:Array[StoryFlag]

func initialize(): load_flag_raw()

## 当故事旗帜变化时
signal flag_changed


## 载入所有flag
func load_flag_raw():
    print("[StoryFlagHandler]正在载入flag_data")
    var dir = DirAccess.open(PATH)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        if !OS.is_debug_build():
            file_name = file_name.get_basename()
        print("文件名:",file_name)
        while file_name != "":
            if !dir.current_is_dir():
                var item:StoryFlag = load(PATH+"/" + file_name )
                print("文件名:",file_name)
                story_flag_raw.append(item) 
            file_name = dir.get_next()
            if !OS.is_debug_build():
                file_name = file_name.get_basename()
        dir.list_dir_end()
    else: print("没有该目录")

func add_flag(flag_name):
    if story_flag_raw.is_empty():
        push_error("story_flag库是空的，请检查")
        return 
    var filters = story_flag_raw.filter(func(item): return item.flag_name == flag_name)
    if filters.is_empty():
        print_debug("添加的flag不存在")
        return
    if filters.size() >=2:
        push_error("flag库中存在同名的flag,请检查")
        return
    story_flag.append(filters[0])
    flag_changed.emit()

func has_flag(flag_name:String) -> bool:
    var _exist = story_flag.filter(
        func(item): return item.flag_name == flag_name
    )
    if _exist.is_empty(): return false
    return true