extends BaseEventNode
class_name  ConditionData

## 脚本命令
@export var script_cmd:String
var condition_result:int

func _init(cmd:int = BaseEventNode.Scripts,pos:Vector2 = Vector2.ZERO,script_cmd:String = "") -> void:
	self.node_type = cmd
	self.pos = pos
	self.script_cmd = script_cmd
## 重写next
func next(index:int=0) -> BaseEventNode:
	return super.next(condition_result)

## 在游戏中执行事件
func _execute(event):
	var condition =  await SceneManager.condition_eval(script_cmd)
	print("condition=",condition)
	condition_result = 0 if condition else 1
	print("%s事件执行完成" % script_cmd)
