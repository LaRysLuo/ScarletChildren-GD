extends Control
class_name ViewNumberInput


## 道具列表
var item_list:Array:
    get: return get_node("HBoxContainer").get_children().filter(func(item):return item is ViewNumberItem)


var select_index:int = 0
var last_index:int = -1

signal on_submit(val) # 对外使用
signal on_select_changed 

func _ready() -> void:
    InputManager.on_action_pressed.connect(on_action)
    select(0)

## 选择
func select(index:int):
    if  select_index != index:
        last_index = select_index
    select_index = index
    var actived:ViewNumberItem = item_list[index]
    on_select_changed.emit()
    actived.active()
    
    var lasted:ViewNumberItem = item_list[last_index]
    lasted.deactive()


func on_action(key:int):
    match  key:
        0: cursor_up()#下
        1: cursor_left()#左
        2: cursor_right()#右
        3: cursor_down()#上
        4: submit()
        5: cancel()

func cursor_left():
    if select_index == 0: return
    select(select_index -1)

func cursor_right():
    if select_index >= item_list.size() - 1: return
    select(select_index + 1)

func cursor_up():
    item_list[select_index].plus(-1)
    pass

func cursor_down():
    item_list[select_index].plus(+1)

## 提交
func submit():
    var output =""
    for item:ViewNumberItem in item_list:
        output += item.get_value()
    # print("output",output)
    on_submit.emit(output)

## 取消。
func cancel():
    on_submit.emit(null)
    pass