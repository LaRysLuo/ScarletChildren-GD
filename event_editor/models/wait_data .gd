extends BaseEventNode
class_name WaitData

@export var time:float

func _init(_cmd:int = BaseEventNode.Wait,_pos:Vector2 = Vector2.ZERO,_time:float =0) -> void:
	self.node_type = _cmd
	self.pos = _pos
	self.time = _time

## 重写父类虚方法
func _execute(_ent:Event,_args):
	var timer = GameManager.get_tree().create_timer(time)
	await timer.timeout
