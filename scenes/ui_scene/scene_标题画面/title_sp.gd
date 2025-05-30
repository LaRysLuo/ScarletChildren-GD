extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ui_info: Control = $"UI信息"

var is_action:bool =false

var tween:Tween

#region  生命周期重载
func _ready() -> void:
	AudioManager.start_music("theme")

func _enter_tree() -> void:
	InputManager.on_action_pressed.connect(_action_input)

func _exit_tree() -> void:
	InputManager.on_action_pressed.disconnect(_action_input)

#endregion

#region 信号函数
func _action_input(key:int) -> void:
	if is_action: return
	if key == InputManager.KEY_A:
		_start_game2()
		# _test_game1()

#endregion

#region 内部函数

# 游戏开始	
func start_game():
	self.is_action = true
	await AudioManager.play_se("Confirm")
	  #AudioManager.
	# 停止播放音乐	
	animation_player.play("确定")
	await animation_player.animation_finished
	# 隐藏UI
	if tween: tween.kill()
	tween = create_tween()
	var target = Color(1, 1, 1, 0) 
	tween.tween_property(ui_info,"modulate",target,0.3)
	print("游戏开始")
	# 雾气加重
	animation_player.play("雾气变浓")
	await  animation_player.animation_finished
	
	# 进入别的场景
	SceneManager.goto("res://scenes/maps/蔷薇馆·中厅1F/map_蔷薇馆·中厅.tscn",false)
	
	pass	

# 开始游戏
func _start_game2():
	self.is_action = true
	await AudioManager.play_se("Confirm")
	AudioManager.stop_music(true)
	animation_player.play("确定")
	await animation_player.animation_finished
	if tween: tween.kill()
	tween = create_tween()
	var target = Color(1, 1, 1, 0) 
	tween.tween_property(ui_info,"modulate",target,0.3)
	
	SceneManager.move("res://scenes/maps/蔷薇馆·中厅1F/map_蔷薇馆·中厅.tscn")

func _test_game1():
	# Core.camera.camera_move()
	pass

#endregion
