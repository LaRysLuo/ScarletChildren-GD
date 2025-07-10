extends InputableScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ui_info: Control = $"UI信息"

var is_action:bool =false


## 标题菜单组件
var title_menu:MenuV2:
	get: return get_node("MenuV2")




var tween:Tween

#region  生命周期重载
func _ready() -> void:
	AudioManager.start_music("theme")
	_init_handlers()
	_init_menu_handler()
	activate()


#endregion

#region 内部函数

func _init_handlers():
	set_handler("ok",_handle_show_menu)

func _init_menu_handler():
	title_menu.set_handler("new_game",_start_game2)
	title_menu.set_handler("load_game",_handle_load_game)
	title_menu.on_select_sfx.connect(func(): Interpreter.play_se("select03"))
	if Save.exist():
		print("[Save]读取到存档")
		title_menu.get_btn("load_game").disable = false


func _handle_show_menu():
	remove_handler("ok")
	deactivate()
	await AudioManager.play_se("Confirm")
	animation_player.play("确定")
	await animation_player.animation_finished
	title_menu.activate()

	
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
	if tween: tween.kill()
	tween = create_tween()
	var target = Color(1, 1, 1, 0) 
	tween.tween_property(ui_info,"modulate",target,0.3)
	
	SceneManager.move("res://scenes/maps/0序章/0_START/Start.tscn")

func _handle_load_game():
	print("[Title]触发了显示scene_load")
	title_menu.deactivate()
	var scene:SceneLoad =  await UIManager.show_ui("scene_load")
	scene.show_with_load()
	scene.on_confirm.connect(func(): 
		AudioManager.stop_music(true)
		UIManager.pop_ui(scene)
		# queue_free()
		)
	scene.on_cancel.connect(func(): 
		print("[SceneLoad]退出载入页面了")
		title_menu.activate())

#endregion
