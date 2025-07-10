extends Control

## 这是测试用

var start_test_btn:Button:
    get: return get_node("Button")

func _ready() -> void:
    start_test_btn.pressed.connect(_play_op)

func _play_op() -> void:
    SceneManager.goto("scene_demo02_with_op")
    queue_free()