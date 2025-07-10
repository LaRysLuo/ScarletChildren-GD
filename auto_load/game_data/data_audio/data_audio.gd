extends Node
class_name DataSound


## 声音数据
## 储存声音资料的数组
var sound_dict = {
    
    ## MUSIC
    "bgm_001": preload("res://audio/bgm/theme.mp3"),


    ## 以下音乐作者：黑耀耀_officialてす 百度网盘下载中……
    "熵增禁域":preload("res://audio/bgm/恐怖悬疑音乐包/熵增禁域（场景探索）.wav"),

    ## SFX

    # UI操作
    "confirm":preload("res://audio/se/Confirm.mp3"),
    "select03":preload("res://audio/se/select03.mp3"),
    # "select03":preload("res://audio/se/ui-button-cursor.mp3"),
    "cancel":preload("res://audio/se/ui-pop-sound-316482.mp3"),
    "poka02":preload("res://audio/se/poka02.mp3"),
    "blip03":preload("res://audio/se/blip03.mp3"),
    "bag_open": preload("res://audio/se/swish.mp3"),

    "fault":preload("res://audio/se/fault.mp3"),


    "rain":preload("res://audio/se/rain.mp3"),

    ## 相机
    "camera":preload("res://audio/se/camera2.mp3"),

    ## 门被打开的声音 - 爱给网
    "old_door_open": preload("res://audio/se/old_door_open.mp3"),
    "door_open_01":preload("res://audio/se/wood_door_open.mp3"),

    ## 脚步声 - 小森平音效
    "walking_on_the_earth":preload("res://audio/se/walking_on_the_earth.mp3"),
    "dashing": preload("res://audio/se/dashing.mp3"),

    ## 钢琴声 - 小森平
    "horror_piano_chord1":preload("res://audio/se/horror_piano_chord1.mp3"),

    ## 人声 - 爱给网
    "female_voice":preload("res://audio/se/female_voice.mp3"),
    "female_laughing":preload("res://audio/se/female_laughing.mp3"),
    "female_laughing_02":preload("res://audio/se/female_laughing_02.mp3"),

    ## 恶魔的声音 - 小森平
    "devil_laughing1": preload("res://audio/se/devil_laughing1.mp3"),

    "coin_01":preload("res://audio/se/coin_agei_01.mp3"),

    ## 翅膀的声音 - 爱给网
    "wing_01":preload("res://audio/se/wing.mp3"),
    "wing_02":preload("res://audio/se/wing_02.mp3"),

    ## 奇怪的音效
    "hop":preload("res://audio/se/hop.mp3"),
    "suspicion":preload("res://audio/se/suspicion1.mp3")

}


func _ready() -> void:
    pass

## 获取声音
func get_sound(_audio_name:String) -> AudioStream:
    var _audio = sound_dict.get(_audio_name,null)
    if !_audio:
        push_error("找不到名为%s的音频，是否还没有在DataSound上注册" % _audio_name)
        return
    return _audio


