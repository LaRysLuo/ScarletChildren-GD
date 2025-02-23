extends Node2D
class_name AudioManager


#region 静态变量和函数

## 创建时的回调
static var on_created:Callable

static func set_on_created(_on_created:Callable):
	AudioManager.on_created = _on_created

#endregion

const FILE_TYPES = [ '.ogg','.wav','.mp3']
var audio_player:AudioStreamPlayer:
	get(): return get_node("MusicPlayer")
var se_player:AudioStreamPlayer:
	get(): return get_node("SePlayer")
const root_path = "res://audio/bgm/"
const se_root_path = "res://audio/se/"

signal se_finish

## 播放八音盒音乐
func play_musicalbox():
	start_music("musical_box")
	
func play_puzzle_complete():
	play_se("putting1")
	
## 播放"颠倒" 音效
func play_terror():
	play_se("terror")

## 播放“故障”音效
func play_fault():
	play_se("fault")

func play_damage4():
	play_se("damage4")

## 怪物笑声
func play_monster_laughing():
	play_se("laughing1_fx")

## 开门
func play_door_open():
	play_se("room_door_O")

## 关门
func play_door_close():
	await play_se("room_door_C")	

func play_knocking():
	await  play_se("knocking_an_iron_door1")

func play_breaker():
	await play_se("cutting_a_breaker")

## 出现
func play_show():
	await  play_se("monster_show")

## 摔倒
func play_tumbling2():
	await  play_se("tumbling2")

func play_monster_roaning2():
	await  play_se("monster_roaning2")

## 电流声
func play_electrical_sound():
	await  play_se("electrical_sound")

## 播放光标移动
func play_cursor_move():
	play_se("Cursor1")
	
## 疑惑
func play_suspicion1():
	play_se("suspicion1")
	
## 玻璃滚动声
func play_glass_down():
	play_se("putting_a_glass1")
	
## 不能使用
func play_buzzle():
	play_se("blip03")
	
## 翻页
func play_turnpage():
	play_se("page")

func _ready() -> void:
	self.hide()

# func set_root_path(path):
# 	root_path = path

## 播放音乐
## file_name 音乐文件名称
## vol 音量
func start_music(_file_name:String,_vol:float = 0):
	var stream := find_file_by_type(_file_name,1)
	if stream:
		print("开始播放音乐：",stream)
		audio_player.stream = stream
		audio_player.volume_db = 0
		audio_player.play()

# 停止播放
func stop_music(fade:bool=false):
	print("停止播放")
	if fade:
		var tween = create_tween()
		tween.tween_property(audio_player,"volume_db",-30,0.6)
		await  tween.finished
	audio_player.stop()
	audio_player.stream = null
	pass

func play_se(file_name):
	if !file_name: return
	var stream := find_file_by_type(file_name,2)
	if stream:
		se_player.stream =stream
		se_player.play()
		await  se_player.finished
		se_finish.emit()

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
