extends Node

func _ready() -> void:
    AudioManager.set_on_created(add_global_node)

## 添加全局节点
func add_global_node(node:Node):
    add_child(node)