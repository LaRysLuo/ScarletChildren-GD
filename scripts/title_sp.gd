extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ui_info: Control = $"UI信息"
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


var tween:Tween


# 检查任意键被按下
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("submit"):
		start_game()

# 游戏开始	
func start_game():
	AudioManager.play_se("Confirm")
	await  AudioManager.se_finish
	# 停止播放音乐
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(audio_stream_player_2d,"volume_db",-30,0.6)
	tween.finished.connect(func():
		audio_stream_player_2d.stop()
	)
	
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
