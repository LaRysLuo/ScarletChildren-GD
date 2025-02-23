extends Node2D
class_name SceneLoader


@export var scene_path:String

## 移动到场景
func goto():
    await  GameManager.scene_manager.goto(scene_path)
    pass

func move():
    await GameManager.scene_manager.move(scene_path)
    pass