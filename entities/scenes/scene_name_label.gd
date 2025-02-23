extends Panel
class_name SceneNameLabel

	
var scene_name_label:Label:
	get():return get_node("./Label")

## 获得当前场景
func _ready() -> void:
	## 怎么获取到GameScene，SceneManager.current_map_name的名字
	pass
	set_info(GameManager.scene_manager.current_map_name)
	# scene_name_label.text = "位置：%s" % str(SceneManager.current_map_name)

func set_info(scene_name:String) -> void:
	scene_name_label.text = "位置：%s" % scene_name