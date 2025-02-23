extends BaseEventNode
class_name ScriptData

## 脚本命令
@export var script_cmd:String

func _init(cmd:int = BaseEventNode.Scripts,pos:Vector2 = Vector2.ZERO,script_cmd:String = "") -> void:
	self.node_type = cmd
	self.pos = pos
	self.script_cmd = script_cmd

## 在游戏中执行事件
func _execute(event,args):
	# await SceneManager.eval(script_cmd)
	print("%s事件执行完成" % script_cmd)
