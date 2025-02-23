extends Node2D

## CORES


## 游戏管理器
var game

var emitsc_enter:EmitsCenter:
    get(): return get_node("EmitsCenter")

## 镜头管理器
# var camera:Camera: 
#     get(): return get_node("Camera")

## 输入管理器
var input_manager:InputManager: 
    get(): return get_node("Input")


## 音频管理器
var audio_manager:AudioManager:
    get(): return get_node("AudioManager")

## 场景管理器
var scene_manager:SceneManager:
    get(): return get_node("SceneManager")


## 对话管理器
var dialogue

## 角色控制器
var characters


func _ready() -> void:
    _init_emits_center()

## 初始化emits
func _init_emits_center():
    emitsc_enter.add_emit("start_theme_music",func(): audio_manager.start_music("theme") )


func _init_input_manager():
    # emitsc_enter.add_emit("action_input",input_manager.on_action_pressed)
    pass


func _init_scene_manager():
    ## 每次场景变化的时候连接输入管理器的信号
    scene_manager.on_scene_changed.connect(func(current:Node):
    
            if current.has_method("action_input"):
                input_manager.on_action_pressed.connect(current.get_method("action_input")
        )
    )
