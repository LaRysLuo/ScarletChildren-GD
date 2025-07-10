extends BaseEventNode
class_name ItemlinkData

## 道具的item_id
@export var item_id:String

func _init(_node_type:int = 0,_pos:Vector2 = Vector2.ZERO,_item_id="") -> void:
	self.node_type = _node_type
	self.pos = _pos
	self.item_id = _item_id

## 获取回调
func get_call() -> BaseEventNode:
	const from_port_index = 0
	var filters:Array[ChildrenNodeConfig] = children.filter(func(item:ChildrenNodeConfig):return item.from_port_index == from_port_index)
	if filters.is_empty():return null
	return filters[0].child
