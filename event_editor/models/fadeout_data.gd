extends BaseEventNode
class_name FadeoutData

@export var time:float = 0.5

func _init(node_type:int = BaseEventNode.Scripts,pos:Vector2 = Vector2.ZERO,time:float = 0) -> void:
	super._init(node_type,pos)
	self.time = time

func _execute(ent,args):
	print("淡出画面",time)
	#GameManager.set_screen_color(ColorScreen.BLACK)
	await  GameManager.fadeout_black(time)
	#await SceneManager.fadeout()
