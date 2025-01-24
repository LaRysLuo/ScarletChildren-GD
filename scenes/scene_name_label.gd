extends Panel
class_name SceneNameLabel

	
var scene_name_label:Label:
	get():return get_node("./Label")

## 获得当前场景
func _ready() -> void:
	scene_name_label.text = "位置：%s" % str(SceneManager.current_map_name)
