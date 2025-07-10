extends BaseEventNode
class_name FadeinData

@export var time:float = 0.5

func _init(_node_type:int = BaseEventNode.Scripts,_pos:Vector2 = Vector2.ZERO,_time:float = 0.5) -> void:
	super._init(_node_type,_pos)
	self.time = _time
	

func _execute(_ent,_agrs):
	print("淡入画面")
	await  GameManager.fadein(time)
