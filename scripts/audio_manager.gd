extends Node2D

const FILE_TYPES = [ '.ogg','.wav','.mp3']
@onready var audio_player = $MusicPlayer
@onready var se_player = $SePlayer
@onready var root_path = "res://audio/"
@onready var se_root_path = "res://audio/se/"

signal se_finish

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	pass # Replace with function body.

func set_root_path(path):
	root_path = path
	pass

# 播放音乐
func start_music(file_name):
	var stream := find_file_by_type(file_name,1)
	if stream:
		audio_player.stream =stream
		audio_player.play()
	pass

# 停止播放音乐
func stop_music():
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
	

# 从特定类型中找到音频文件
func find_file_by_type(file_name,mode) -> AudioStream :
	var stream = null
	var root = root_path if mode == 1 else se_root_path
	for type in FILE_TYPES:
		var full_path = root + file_name + type
		stream = load(full_path) as AudioStream
		if stream: break
	return stream
