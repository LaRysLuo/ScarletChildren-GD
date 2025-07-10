extends InputableScene
class_name SceneLoad

## 该页面共三个功能
# 1. 载入
# 2. 照片管理- 删除照片，空出空位
# 3. 拍照成功的提示：拉起窗口，选择在新增的照片上


const SCENE_ITEM_RES = preload("res://scenes/ui_scene/scene_save/save_item.tscn")

## 存档单元
var grid:Control:
    get: return get_node("PanelContainer/VBoxContainer/MarginContainer/Grid")

var save_file_list:Array:
    get: return Save.get_save_data_list()

func _ready() -> void:
    
    call_deferred("_render_save_items")
    # call_deferred("select",1,true)
    activate()

# func _fade_in(time:float = 0.5) -> void:
#     var tween = create_tween()
#     tween.tween_property(self,"modulate:a",1,time)
#     tween.set_ease(Tween.EASE_OUT)
#     await  tween.finished


## 在标题页面显示
func show_with_load():
    _init_handler1()
    # await _fade_in()



## 以存档成功
func show_with_readonly(slot:int):
    set_handler("ok",_cancel)
    call_deferred("select",slot,true)
    # select(slot)
    # _fade_in()

## 选择索引
var selcted_index:int = 0

## 存档单位列表
var save_item_list:
    get: return grid.get_children()


signal on_confirm
signal on_cancel

func _init_handler1():
    set_handler("cursor_move",_cursor_move)
    set_handler("ok",_confirm)
    set_handler("cancel",_cancel)

func _render_save_items():
    var index:int = 0
    for data in save_file_list:
        var _item:SaveItem = SCENE_ITEM_RES.instantiate()
        if data:
            var info:SaveData  = Save.get_save_data_info(data,index)
            _item.set_value(index,info)
        else: _item.set_value(index,null)
        grid.add_child(_item)
        index += 1
    select(0,true)

func select(_select_index:int,ingore_se:bool = false):
    if self.selcted_index != _select_index:
        var lasted:SaveItem = save_item_list[self.selcted_index]
        lasted.deactive()
    self.selcted_index = _select_index
    var selected:SaveItem = save_item_list[self.selcted_index]
    selected.active()
    if !ingore_se: Interpreter.play_se("select03")

func _cursor_move(key:int):
    match key:
        LEFT:_cursor_left()
        RIGHT: _cursor_right()

func _cursor_left(): 
    if selcted_index <= 0: return
    select(selcted_index - 1)


func _cursor_right():
    if selcted_index >= save_item_list.size() - 1: return
    select(selcted_index + 1)

## 确认选择
func _confirm():
    ## 1. 判断是否可载入
    var selected:SaveItem = save_item_list[self.selcted_index]
    if !selected || selected.is_empty(): 
        print("[Save]该存档不可以")
        Interpreter.play_se("blip03")
        return
   
    ## 确定载入这个存档吗,出现选项A或者B 
    Interpreter.play_se("confirm")
    ## TODO 载入游戏的逻辑
    await  Save.load_data(selected.data.slot_id)
    on_confirm.emit()

## 取消选择
func _cancel():
    UIManager.pop_ui(self)
    on_cancel.emit()
