@tool
extends Resource
class_name VariableData

## Variable资源类

@export var key:String # 键
@export var type:int # 类型
@export var initial_value:Variant = null # 初始值
@export var saved_value:Variant = null # 储存值
	

## 构造函数
func _init(_key:String = "",_type:int = 0,_initial_value:Variant = null,_saved_value:Variant = null) -> void:
	self.key = _key
	self.type = _type
	self.initial_value = _initial_value
	self.saved_value = _saved_value

func get_value():
	if self.saved_value: return self.saved_value
	else: return initial_value

func reset():
	saved_value = initial_value
