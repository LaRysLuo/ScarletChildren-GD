extends VisiableTriggerNode2D
class_name Music

## 当该组件是可见时，自动播放音乐
## 当该组件隐藏时，停止播放音乐

## 请确保该music_id在AudioManager的data_sound中注册了
@export var music_id:String

func _on_show():
    if music_id == "": 
        print("[Music]未设置音乐")
        return
    print("[Music]开始播放音乐")
    var _audio  = GameManager.game_data.data_sound.get_sound(music_id)
    AudioManagerV2.play_music(_audio)

func _on_hide():
    AudioManagerV2.stop_music()


