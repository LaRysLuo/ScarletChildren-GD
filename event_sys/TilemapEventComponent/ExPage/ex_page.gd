@icon("res://assets/icon/stair.png")
@tool
extends BasePage
class_name ExPage


## PageHandler
var handler:Node2D:
    get: return get_parent()

var maps:TileMapLayer:
    get: return handler.get_parent().get_node("Maps/Objects")


## 坐标
@export var pos:Vector2i:
    set(val):
        pos = val
        _init_pos()

## 类型资源
@export var content:EventEx


func _init_pos():
    if !Engine.is_editor_hint(): return
    self.position = maps.map_to_local(pos)