
## 音频播放器
@icon("res://editor/icon/audio.png")
extends LarikExtNode
class_name AudioPlayer


static var instance:AudioManager

var manager:AudioManager:
	get(): 
		if !instance:   
			if !instance.on_created:
				push_error("未配置AudioManager,请使用AudioManager.set_on_created来配置") 
				return
			instance =	instance.on_created.call(instance)
		return instance



func play_se(se_name:String):
	if manager: await manager.play_se(se_name)

func start_music(music_name:String): 
	if manager: manager.start_music(music_name)

func stop_music(fade:bool):
	if manager:manager.stop_music(fade)
