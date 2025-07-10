extends BaseEventNode
class_name AudioPlayerData

@export var type:int ## 操作类型：播放音乐10、播放音效20等
@export var audio_code:String ## 音频代码
@export var is_wait:bool ## 是否等待播放完

## 设定每个操作类型的字典
var FUNC_DICT = {
	10: _play_music, # 播放音乐
	20: _play_sfx, # 播放音效
}

func _init(_cmd:int = BaseEventNode.Wait,_pos:Vector2 = Vector2.ZERO,_type:int =0,_audio_code = "",_is_wait = false ) -> void:
	self.node_type = _cmd
	self.pos = _pos
	self.type = _type
	self.audio_code = _audio_code
	self.is_wait = _is_wait



## 重写父类虚方法
func _execute(_ent:Event,_args):
	print("操作类型为：",type)
	var _call = FUNC_DICT.get(type)
	if not _call: 
		push_error("[AudioPlayerData]错误的操作类型")
		return
	if not _call is Callable:
		push_error("[AudioPlayerData]配置的操作类型回调函数错误，它可能并不是一个回调函数")
		return
	_call.call()

## 播放音乐
func _play_music():
	Interpreter.play_music(audio_code)

## 播放音效
func _play_sfx():
	await  Interpreter.play_se(audio_code,is_wait)

