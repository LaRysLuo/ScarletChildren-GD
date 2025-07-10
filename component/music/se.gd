extends VisiableTriggerNode2D
class_name Se

## 当该组件是可见时，自动播放音乐
## 当该组件隐藏时，停止播放音乐

## 请确保该music_id在AudioManager的data_sound中注册了
@export var se_id:String

func _on_show():
	if se_id == "": 
		print("[Se]未设置音效")
		return
	print("[Se]开始播放音效")
	var _audio  = GameManager.game_data.data_sound.get_sound(se_id)
	await AudioManagerV2.play_sfx(_audio)
	visible = false

func _on_hide():
	pass
