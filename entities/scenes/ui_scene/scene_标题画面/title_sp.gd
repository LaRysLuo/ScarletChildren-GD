extends Control

# 引用组件
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ui_info: Control = $"UI信息"
@onready var input:InputDispatcher = $InputDispatcher
@onready var scene_loader:SceneLoader = $SceneLoader


## 引用音频播放器
var audio_player:AudioPlayer: 
	get(): return get_node("AudioPlayer")



var is_action:bool =false

var tween:Tween

#region  生命周期重载
func _ready() -> void:
	input.on_action_pressed.connect(_action_input)
	audio_player.start_music("theme")

	

func _exit_tree() -> void:
	input.on_action_pressed.disconnect(_action_input)

#endregion

#region 信号函数
func _action_input(key:int) -> void:
	if is_action: return

	if key == input.KEY_A:
		_start_game2()
		# _test_game1()

#endregion

#region 内部函数

# 开始游戏
func _start_game2():
	self.is_action = true
	await audio_player.play_se("Confirm")
	audio_player.stop_music(true)
	animation_player.play("确定")
	await animation_player.animation_finished
	if tween: tween.kill()
	tween = create_tween()
	var target = Color(1, 1, 1, 0) 
	tween.tween_property(ui_info,"modulate",target,0.3)
	scene_loader.move()
	# SceneManager.move("res://scenes/maps/蔷薇馆·中厅1F/map_蔷薇馆·中厅.tscn")

#endregion
