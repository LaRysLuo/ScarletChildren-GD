extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ui_info: Control = $"UI信息"


var tween:Tween


# 检查任意键被按下
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("submit"):
		start_game2()

func _ready() -> void:
	AudioManager.start_music("theme")

# 游戏开始	
func start_game():
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
	SceneManager.goto("maps/Map_2梦境",false)
	
	pass	

# 开始游戏
func start_game2():
	await AudioManager.play_se("Confirm")
	AudioManager.stop_music(true)
	animation_player.play("确定")
	await animation_player.animation_finished
	if tween: tween.kill()
	tween = create_tween()
	var target = Color(1, 1, 1, 0) 
	tween.tween_property(ui_info,"modulate",target,0.3)
	pass
