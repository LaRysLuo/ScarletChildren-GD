extends Node2D

const FILE_TYPES = [ '.ogg','.wav','.mp3']
@onready var audio_player:AudioStreamPlayer = $MusicPlayer
@onready var se_player = $SePlayer
@onready var root_path = "res://audio/bgm/"
@onready var se_root_path = "res://audio/se/"

signal se_finish

## 播放八音盒音乐
func play_musicalbox():
	start_music("musical_box")
	
func play_puzzle_complete():
	play_se("putting1")
	
## 播放光标移动
func play_cursor_move():
	play_se("Cursor1")
	
func play_glass_down():
	play_se("putting_a_glass1")
	
func play_buzzle():
	play_se("blip03")
	
func play_turnpage():
	play_se("page")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	
	pass # Replace with function body.

func set_root_path(path):
	root_path = path
	pass

## 播放音乐
## file_name 音乐文件名称
## vol 音量
func start_music(file_name:String,vol:float = 0):
	var stream := find_file_by_type(file_name,1)
	if stream:
		print("开始播放音乐：",stream)
		audio_player.stream = stream
		audio_player.volume_db = 0
		audio_player.play()
	pass

# 停止播放
func stop_music():
	print("停止播放")
	audio_player.stop()
	audio_player.stream = null
	pass

func play_se(file_name):
	var stream := find_file_by_type(file_name,2)
	if stream:
		se_player.stream =stream
		se_player.play()
		await  se_player.finished
		se_finish.emit()
		pass

func stop_se():
	print("停止播放")
	se_player.stop()
	se_player.stream = null


# 从特定类型中找到音频文件
func find_file_by_type(file_name,mode) -> AudioStream :
	var stream = null
	var root = root_path if mode == 1 else se_root_path
	for type in FILE_TYPES:
		var full_path = root + file_name + type
		#print("寻找地址:%s" % full_path)
		if ResourceLoader.exists(full_path):
			stream = load(full_path) as AudioStream
			if stream: 
				#print("找到了：%s" % full_path)
				break
	return stream
