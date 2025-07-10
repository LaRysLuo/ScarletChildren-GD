extends BaseEventNode
class_name ScriptData

## 脚本命令
@export var script_cmd:String

func _init(_cmd:int = BaseEventNode.Scripts,_pos:Vector2 = Vector2.ZERO,_script_cmd:String = "") -> void:
	self.node_type = _cmd
	self.pos = _pos
	self.script_cmd = _script_cmd

## 在游戏中执行事件
func _execute(_event,_args):
	await Interpreter.eval(script_cmd,_event)
	print("%s事件执行完成" % script_cmd)
