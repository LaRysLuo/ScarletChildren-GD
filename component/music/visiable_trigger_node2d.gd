extends Node2D
class_name VisiableTriggerNode2D

## 这是一个可视度变化时，会有对应生命周期的函数
# 可作为有这类需求的基类
# 请不要把这个基类直接挂载到组件上，请继承该类使用

func _ready() -> void:
    visibility_changed.connect(_on_visibility_changed)
    if visible:_on_show()

func _on_visibility_changed():
    if visible: _on_show()
    else: _on_hide()

func _on_show():
    print("节点变为可见了")
    pass

func _on_hide():
    print("节点变为不可见了")
    pass