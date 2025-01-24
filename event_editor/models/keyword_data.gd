extends BaseEventNode
class_name KeywordData

@export var keyword:String

func _init(node_type:int = 0,pos:Vector2 = Vector2.ZERO,keyword="") -> void:
	self.node_type = node_type
	self.pos = pos
	self.keyword = keyword

## 获得思考回调
func get_call() ->BaseEventNode:
	const from_port_index = 0
	var filters:Array[ChildrenNodeConfig] = children.filter(func(item:ChildrenNodeConfig):return item.from_port_index == from_port_index)
	if filters.is_empty():return null
	return filters[0].child
	

## 获得物品联想节点
func get_item_link() -> ItemlinkData:
	const from_port_index = 1
	var filters:Array[ChildrenNodeConfig] = children.filter(func(item:ChildrenNodeConfig):return item.from_port_index == from_port_index)
	if filters.is_empty():return null
	return filters[0].child

## 获得物品未匹配到
func get_none_matched() -> BaseEventNode:
	const from_port_index = 2
	var filters:Array[ChildrenNodeConfig] = children.filter(func(item:ChildrenNodeConfig):return item.from_port_index == from_port_index)
	if filters.is_empty():return null
	return filters[0].child
