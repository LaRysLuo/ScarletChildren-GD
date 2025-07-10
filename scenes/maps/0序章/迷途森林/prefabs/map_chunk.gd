extends Node2D
class_name MapChunk

## 获得移动层
func get_movable():
    return get_node("Movable")