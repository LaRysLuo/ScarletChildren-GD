extends Node
class_name AnimationScene

## 动画场景
# 在这个场景下必须要有一个AnimationPlayer

var animation_player:AnimationPlayer

signal finished

func _ready() -> void: _trigger()

## 尝试获取子节点的动画播放器
func try_get_animation_player():
    var filters = get_children().filter(func(item):return item is AnimationPlayer)
    if filters.is_empty(): 
        push_error("AnimationScene组件没有找到animation_player")
    animation_player = filters[0]

func _trigger(): 
    try_get_animation_player()
    for anim in animation_player.get_animation_list():
        animation_player.current_animation = anim
        animation_player.play()
        await  animation_player.animation_finished
    await SceneManager.backto(finished)
    
    
