class_name CGShowToolV2

const base_scene = preload("res://auto_load/cgshow_tool/cg_base_scene/cg_base_scene.tscn")
const BASE_SCENE_NAME = "CGBaseScene"

## 获取承载场景
static  func get_base_scene_entity() -> CGBaseScene:
    if SceneManager.has_node(BASE_SCENE_NAME):
        return SceneManager.get_node(BASE_SCENE_NAME)
    else: return null

## 显示cg
static func show_cg(file_name:String):
    ## 1. 生成预制体
    var scene:CGBaseScene = get_base_scene_entity()
    if not scene:
        scene = base_scene.instantiate() 
        SceneManager.add_child(scene)
    
    ## 2. 读取图片
    var texture = load(file_name)
    if !texture: 
        push_error("没有找到图片")
        return
    ## 3. 显示图片
    scene.set_cg(texture)
    scene.name = BASE_SCENE_NAME



## 隐藏cg
static func hide_cg():
    var _base_scene = get_base_scene_entity()
    _base_scene.get_parent().remove_child(_base_scene)
    _base_scene.queue_free()
