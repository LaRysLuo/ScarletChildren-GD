extends InputableScene
class_name PhoneMenu

"""
TODO LIST:
    1. 增加切换到背包的功能:礼诗收起手机,放回包中,并检视背包中的物品
     - 按X键切换到背包视图
     - 长按后退键
    2. 手机页面时间的显示
    3. 手机页面地点的显示
"""

const app_data_list = [
    {
        "name":"通讯录",
        "icon": preload("res://scenes/ui_scene/scene_main_v2/assets/话筒-copy (1).png"),
        "symbol":"contact"
    },
    {
        "name":"备忘录",
        "icon":preload("res://scenes/ui_scene/scene_main_v2/assets/备忘.png"),
        "symbol":"memo"
    },{
        "name":"资料库",
        "icon":preload("res://scenes/ui_scene/scene_main_v2/assets/知识库.png"),
        "symbol":"file"
    },{
        "name":"设置",
        "icon": preload("res://scenes/ui_scene/scene_main_v2/assets/设置.png"),
        "symbol":"config"
    },{
        "name":"相机",
        "icon":preload("res://scenes/ui_scene/scene_main_v2/assets/相机.png"),
        "symbol":"camera",
    },{
        "name":"照片",
        "icon":preload("res://scenes/ui_scene/scene_main_v2/assets/照片.png"),
        "symbol":"picture"
    }
]

const APP_DATA_ITEM = {
    "name":"手提袋",
    "icon":preload("res://scenes/ui_scene/scene_main_v2/assets/手提袋.png"),
    "symbol":"item"
}

## 一页的大小
const page_size = 2
## 当前页码
var page_num = 1


## 当前数据的总页码
var max_page_num:int:
    get: return (app_data_list.size() / page_size) + 1

var page_tabs:PageTabs:
    get: return get_node("PhoneBase2/MarginContainer/VBoxContainer/AppMenuVB/PageTabs")


const APP_MENU_RES = preload("res://scenes/ui_scene/scene_main_v2/prefabs/app_menu_item.tscn")

const APP_MENU_ITEM_RES = preload("res://scenes/ui_scene/scene_main_v2/prefabs/app_menu_item_v2.tscn")

var app_grid:Control:
    get: return get_node("PhoneBase2/MarginContainer/VBoxContainer/AppMenuVB/VBoxContainer2")

var row1:Control:
    get: return get_node("PhoneBase2/MarginContainer/VBoxContainer/AppMenuVB/VBoxContainer2/Row1")

# var row2:Control:
#     get:return get_node("PhoneBase2/MarginContainer/VBoxContainer/AppMenuVB/VBoxContainer2/Row2")

var select_index:int = -1
var last_index:int = -1


signal on_page_changed(to:int,from:int)

## APP列表
var app_list:Array[AppMenuItem]




## 音效重写
func _audio_cursor_move():
    Interpreter.play_se("select03")

## 播放音频
func _audio_ok():
    Interpreter.play_se("confirm")

func _audio_error():
    Interpreter.play_se("blip03")


## 生命周期
func _ready() -> void:
    _init_app()
    _init_handlers()
    _init_page_tabs()
    _select(0)


func _init_app() -> void:
    _render_app_menu_list()


func _init_handlers():
    set_handler("cursor_move",_hanlde_cursor_move)
    set_handler("ok",_handle_confirm)



func _init_page_tabs():
    page_tabs.init_page(self.max_page_num,self.page_num)
    on_page_changed.connect(page_tabs.update_page_num)

## 渲染APP列表
func _render_app_menu_list():
    if app_data_list.is_empty(): return
    if !app_list.is_empty(): _clear_app_menu_list()
    print("page_num=",page_num)
    if page_num == 0: 
        _render_app_bag()
        return

    var start = (page_num -1) * page_size
    var end = start + page_size

    # 从列表中取出0-1和2-3的数据
    var _range = end if app_data_list.size() >= end else app_data_list.size()
    var list = app_data_list.slice(start,_range)
    
    # 渲染row1list
    for data in list:
        var app:AppMenuItem = APP_MENU_RES.instantiate()
        app.set_data(data.get("name"),data.get("icon"),data.get("symbol"))
        app_list.append(app)
        row1.add_child(app)
        # else: row2.add_child(app)

func _render_app_bag():
    var app = APP_MENU_ITEM_RES.instantiate()
    app.set_data(APP_DATA_ITEM.get("name"),APP_DATA_ITEM.get("icon"),APP_DATA_ITEM.get("symbol"))
    row1.add_child(app)
    app_list.append(app)


## 清除APP列表
func _clear_app_menu_list():
    for app in app_list:
        app.get_parent().remove_child(app)
        app.queue_free()
    app_list.clear()

## 重写基类的函数
func _handler_action_input(key:int):
    if !_active: return
    super._handler_action_input(key)

## 光标移动
func _hanlde_cursor_move(key:int) -> bool:
    match key:
        LEFT: return _handle_left()
        RIGHT:return _handle_right()
        # UP: return _handle_up()
        # DOWN:return _handle_down()
    return false

## 光标移动 - 左
func _handle_left() -> bool: 
    if select_index  % app_list.size() <= 0: 
        return _handle_page_up()
    _select( select_index - 1)
    return true

## 光标移动 -右
func _handle_right() -> bool:
    if select_index  >= app_list.size() -1: 
        ## 触发向前翻页
        return _handle_page_down()
    _select(select_index + 1)
    return true

## 光标移动 - 上
# func _handle_up() -> bool:
#     if select_index - 2 < 0: return false
#     _select(select_index - 2)
#     return true

# ## 光标移动 - 下
# func _handle_down() ->bool:
#     if select_index + 2 >= app_list.size(): return false
#     _select(select_index + 2) 
#     return true

## 向上翻页
func _handle_page_up() -> bool: 
    if page_num == 0: return false # 已经翻到首页了
    _handle_page_change(page_num - 1)
    return true

## 向下翻页
func _handle_page_down()-> bool:
    if page_num >= max_page_num - 1: return false # 已经翻到最后一页了
    _handle_page_change(page_num+1)
    return true

## 改变页码
func _handle_page_change(index:int):
    # var new_index = 1 if self.select_index % 2 == 0 else 0
    var app_size = 0 if index == 0 else 1
    var new_index = app_size if page_num > index else 0  
    # 将选择重置
    self.select_index = -1
    self.last_index = -1
    on_page_changed.emit(index,self.page_num)
    self.page_num = index
    _render_app_menu_list()
    
    _select(new_index)

func _select(index:int) -> void:
    if select_index == index: return
    self.last_index =  self.select_index
    var last_app:AppMenuItem = app_list[self.last_index]
    last_app.unfocus()
    self.select_index = index
    var app:AppMenuItem = app_list[self.select_index]
    app.focus()


func _handle_confirm():
    var symbol:String = app_list[self.select_index].symbol
    if _handlers.has(symbol): return await  _handlers.get(symbol).call()
    return false
