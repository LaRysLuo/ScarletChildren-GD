extends CanvasLayer
# class_name UIManager

"""
这是一个UI的管理器
它的作用是，管理所有进栈的UI显示，只有在最顶层的UI组件才能进行输入操作

"""

const DICT = {
    # "scene_menu":preload("res://scenes/ui_scene/scene_main/scene_main.tscn"),
    "scene_main":preload("res://scenes/ui_scene/scene_main_v2/scene_main_v2.tscn"),
    "scene_load":preload("res://scenes/ui_scene/scene_save/scene_save.tscn")
}

var grid:Control:
    get:return get_node("GridTrans")

var panel:Control:
    get:return get_node("Panel")


func _ready() -> void:
    panel.hide()

func get_ui_stack() -> Array:
    return grid.get_children()


## 显示UI场景
func show_ui(scene_name:String):
    await Interpreter.fadeout(0.3)
    var packed_scene:PackedScene = DICT.get(scene_name)
    var entity_scene = packed_scene.instantiate()
    _hide_others()
    grid.add_child(entity_scene)
    _refresh_game_state()
    await Interpreter.fadein(0.3)
    return entity_scene

func _hide_others():
    for item in get_ui_stack():
        item.hide()

func pop_ui(scene:Control):
    grid.remove_child(scene)
    scene.queue_free()
    _refresh_game_state()
    _show_front()

func pop_all():
    for item in grid.get_children():
        grid.remove_child(item)
        item.queue_free()
    _refresh_game_state()


func _refresh_game_state():
    if get_ui_stack().is_empty():
        get_tree().paused = false
        panel.hide()
    else:
        panel.show()
        get_tree().paused = true

func _show_front():
    if get_ui_stack().is_empty(): return
    grid.get_child(-1).show()


