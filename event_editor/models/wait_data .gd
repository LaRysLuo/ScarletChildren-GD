extends BaseEventNode
class_name WaitData

@export var time:float

func _init(cmd:int = BaseEventNode.Wait,pos:Vector2 = Vector2.ZERO,time:float =0) -> void:
	self.node_type = cmd
	self.pos = pos
	self.time = time

## 重写父类虚方法
func _execute(ent:Event):
	var timer = GameManager.get_tree().create_timer(time)
	await timer.timeout
