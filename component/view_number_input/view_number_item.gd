extends VBoxContainer
class_name ViewNumberItem

var up_arrow:Control:
    get: return get_node("UpArrow")

var down_arrow:Control:
    get: return get_node("DownArrow")

var label:Label:
    get: return get_node("PanelContainer/Label")



func _ready() -> void:
    deactive()


## 激活该选项
func active():
    up_arrow.modulate.a = 1
    down_arrow.modulate.a = 1
    label.modulate = Color.RED

## 冻结该选项
func deactive():
    up_arrow.modulate.a = 0
    down_arrow.modulate.a = 0
    label.modulate = Color.WHITE

func plus(val:int):
    var num:int =  int(label.text) 
    num += val
    if num < 0: num = 0
    if num > 9: num = 9
    label.text = str(num)

func get_value() -> String:
    return label.text