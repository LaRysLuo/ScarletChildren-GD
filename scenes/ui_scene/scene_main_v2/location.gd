extends Label
class_name Location

## 初始化，获取地址
func _ready():
    self.text = SceneManager.current_map_name
    pass

