@tool
extends Resource
class_name ChildrenNodeConfig

## 用于子类的Node和端口的关系

@export var from_port_index:int = -1
@export var to_port_index:int = -1
@export var child:BaseEventNode

func _init(_from_port_index:int = -1,_to_port_index:int = -1,_child:BaseEventNode = null) -> void:
	self.from_port_index = _from_port_index
	self.to_port_index = _to_port_index
	self.child = _child
