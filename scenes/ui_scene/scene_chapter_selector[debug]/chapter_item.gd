@tool
extends Control
class_name ChapterItem

@export var text:String:
    set(v):
        text = v
        if not label: return
        label.text = text

@export var symbol:String:
    set(v):
        symbol = v

var label:Label:
    get: return get_node("VBoxContainer/Label")

signal on_click

# func _ready() -> void:
#     mouse_filter = Control.MOUSE_FILTER_STOP  # 确保可以接收鼠标事件

func _gui_input(event):
    # print("event：",event)
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        print("点击了该组件")
        on_click.emit(symbol)
