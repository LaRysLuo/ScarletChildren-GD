extends PanelContainer
class_name PageMemo

# {
#     "title":"测试数据",
#     "desc":"我是一条测试数据而已",
#     "symbol":"test"
# },

## 备忘录数据
var list_data:Array[Item]:
    get: return GameManager.game_items.get_items_catagory(2)

# ===========================
# 组件引用
# ===========================
var item_list:ItemListV2:
    get: return get_node("MarginContainer/VBoxContainer/ItemList")

# ==========================
# 信号
# ==========================
signal finished

func _ready() -> void:
    _init_item_list()

func _init_item_list():
    item_list.set_data(_convert_two_dict(list_data))
    item_list.set_handler("cancel",_handle_cancel)
    item_list.on_item_confirm.connect(_handle_use_item)
    item_list.show_window()
    item_list.activate()

func _handle_cancel():
    finished.emit()


func _handle_use_item(_symbol:String):
    Interpreter.play_se("confirm")

## 将道具为特定的字典格式
func _convert_two_dict(_data) -> Array[Dictionary]:
    var result:Array[Dictionary] = []
    for item:Item in _data:
        result.append({
            "title":item.item_name,
            "desc": item.item_desc,
            "symbol":str(item.item_id) 
        })
    return result
