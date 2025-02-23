extends BaseEventNode
class_name FadeinData

@export var time:float = 0.5

func _init(node_type:int = BaseEventNode.Scripts,pos:Vector2 = Vector2.ZERO,time:float = 0.5) -> void:
	super._init(node_type,pos)
	self.time = time
	

func _execute(ent,agrs):
	print("淡入画面")
	await  GameManager.game_screen.fadein(time)
