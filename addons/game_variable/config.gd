@tool
extends Resource
class_name VariableConfig

## 将变量整体作为数组储存起来
#@export var vars:Array[VariableData] = []
@export var vars: Dictionary = {}

func _init(_vars:Dictionary = {}):
	self.vars = _vars
