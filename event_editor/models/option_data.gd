extends BaseEventNode 
class_name OptionData

## id 索引
## name 选项名
## child_index 子类索引 
@export var options:Array[Dictionary] ## 选项 KEY对应的是选项名称，VALUE对应的子分支的索引值

var result = -1

func  _init(_cmd:int = BaseEventNode.Option,_pos:Vector2 = Vector2.ZERO,_options:Array[Dictionary] = []) -> void:
	self.node_type = _cmd
	self.pos = _pos
	self.options = _options

## 返回一个子节点所在选项中的索引
func get_opt_index(port_index:int) -> int:
	var index:int = 0
	for opt in options:
		if opt["child_index"] == port_index:
			return index
		index += 1
	return -1

## 重写父类得next方法，并根据当前索引返回节点
func next(_index:int = 0) -> BaseEventNode:
	if result == -1: return null
	#var filters =  children.filter(func(item:ChildrenNodeConfig):return item.to_port_index == result)
	#if filters.is_empty():return null
	return super.next(result)

### TEST 返回2个节点 或者直接在_execute中运行子线程
#func next2() -> Array[BaseEventNode]:
	#return []


## TODO 待写OPTION的逻辑
func _execute(_ent,_args):
	print("[OptionData]正在运行选项节点")
	DialogueManager.show_options(options)
	result = await DialogueManager.options_finish
	
