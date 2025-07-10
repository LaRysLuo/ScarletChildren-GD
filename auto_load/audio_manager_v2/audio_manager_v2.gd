extends Node
# class_name AudioManagerV2

## 音效管理器


enum Bus{
    MASTER,
    MUSIC,
    SFX,
}

const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

## 音乐播放器的配置
## 音乐播放器的个数，固定死，不能改变
var music_audio_player_count:int = 2 

## 当前播放音乐的播放器序号，默认为0
var current_music_player_index:int = 0
## 音乐播放器存放的数组，方便调用
var music_players:Array[AudioStreamPlayer]

## 音效播放器的配置
#  音效播放器的个数
var sfx_audio_player_count:int = 8
#  音效播放器存放的数组，方便调用
var sfx_players:Array[AudioStreamPlayer]

## 渐变时长
var fade_duration := 1.0

func _ready() -> void:
    print("[声音管理器]:加载成功")
    _init_music_audio_manager()
    _init_sfx_audio_manager()

## 初始化音乐播放器
func _init_music_audio_manager()->void:
    for i in music_audio_player_count:
        var audio_player := AudioStreamPlayer.new()
        audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
        audio_player.bus = MUSIC_BUS
        add_child(audio_player)
        music_players.append(audio_player)

func play_music(_audio:AudioStream) -> void:
    var current_audio_player := music_players[current_music_player_index]
    if current_audio_player.stream == _audio:
        return
    var empty_audio_player_index = 0 if current_music_player_index == 1 else 1
    var empty_audio_player := music_players[empty_audio_player_index]
    # 渐入
    empty_audio_player.stream = _audio
    play_and_fade_in(empty_audio_player)
    # 渐出
    fade_out_and_stop(current_audio_player)
    current_music_player_index = empty_audio_player_index

func stop_music() ->void:
    var current_audio_player := music_players[current_music_player_index]
    fade_out_and_stop(current_audio_player)


## 初始化音效播放器
func _init_sfx_audio_manager() -> void :
    for i in sfx_audio_player_count:
        var player:AudioStreamPlayer = AudioStreamPlayer.new()
        player.bus = SFX_BUS
        add_child(player)
        sfx_players.append(player)

## 播放音效
func play_sfx(_audio:AudioStream,_is_wait:bool = false,_vol:int = 0) -> AudioStreamPlayer:
    var sfx_auido_player:AudioStreamPlayer
    for i in sfx_audio_player_count:
        sfx_auido_player = sfx_players[i]
        if not sfx_auido_player.playing:
            sfx_auido_player.stream = _audio
            if _vol != 0: sfx_auido_player.volume_db = _vol
            else: sfx_auido_player.volume_db = 0
            sfx_auido_player.play()
            if _is_wait: await sfx_auido_player.finished
            break
    return sfx_auido_player

## 停止播放音效:fade是否淡出
func stop_sfx(_fade:bool = false) -> void:
    # var current_audio_player = sfx_players[]
    pass

func play_and_fade_in(_audio_player:AudioStreamPlayer) -> void:
    _audio_player.play()
    var tween:Tween = create_tween()
    tween.tween_property(_audio_player,"volume_db",0,fade_duration)

func fade_out_and_stop(_audio_player:AudioStreamPlayer) -> void:
    var tween:Tween = create_tween()
    tween.tween_property(_audio_player,"volume_db",-40,fade_duration)
    await  tween.finished
    _audio_player.stop()
    _audio_player.stream = null