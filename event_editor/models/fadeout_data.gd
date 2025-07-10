extends BaseEventNode
class_name FadeoutData

@export var time:float = 0.5

func _init(_node_type:int = BaseEventNode.Scripts,_pos:Vector2 = Vector2.ZERO,_time:float = 0) -> void:
	super._init(_node_type,_pos)
	self.time = _time

func _execute(_ent,_args):
	print("淡出画面",time)
	#GameManager.set_screen_color(ColorScreen.BLACK)
	await  GameManager.fadeout_black(time)
	#await SceneManager.fadeout()
