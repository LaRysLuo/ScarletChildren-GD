extends Panel
class_name Tutorial

static var tutorial_entity:Tutorial
static var tutorial_scene:PackedScene = preload("res://component/tutorial_hint/tutorial_panel.tscn")

## 显示教程
static func show_message(message:String,node:Node):
    tutorial_entity = tutorial_scene.instantiate()
    tutorial_entity.set_message(message)
    node.add_child(tutorial_entity)
    tutorial_entity.set_position(Vector2(460,300))


static func hide_message():
    if tutorial_entity:
        ## 教程隐藏
        # tutorial_entity.size().x
        tutorial_entity.get_parent().remove_child(tutorial_entity)
        tutorial_entity.queue_free()

var label:Label:
    get: return get_node("MarginContainer/VBoxContainer/Label2")

func set_message(message:String):
    label.text = tr(message)

# func hide_massage():
