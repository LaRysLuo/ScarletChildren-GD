@tool
extends Resource
class_name KeyTipsConfig

signal  on_value_changed

@export var key_name:StringName = "功能名称":
	set(val):
		key_name = val
		on_value_changed.emit() 
@export var is_show:bool = true:
	set(val):
		is_show =val
		emit_signal("on_value_changed")


func _init(_key_name:StringName = "功能名称",_is_show:bool =true) -> void:
	self.key_name = _key_name
	self.is_show = _is_show
