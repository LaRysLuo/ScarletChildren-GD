extends Control


@onready var first_focus = $VBoxContainer/NewGame
@onready var load_game_btn = $VBoxContainer/LoadGame
@onready var exit_game_btn = $VBoxContainer/ExitGame


func _gui_input(event: InputEvent) -> void:
	print("触发鼠标事件",event)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	#AudioManager.start_music("Theme1")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_focused():
	AudioManager.play_se("Cursor1")
	pass

# 游戏开始被点击
func _on_new_game_pressed() -> void:
	print("游戏开始")
	AudioManager.stop_music()
	SceneManager.goto("main")
	pass



#载入游戏
func _on_load_game_pressed() -> void:
	print("载入游戏")
	pass # Replace with function body.



#离开游戏
func _on_exit_game_pressed() -> void:
	print("离开游戏")
	get_tree().quit()
	pass # Replace with function body.
