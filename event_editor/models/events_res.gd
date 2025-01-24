## 剧情编辑器的资源类
## @author Larik

extends Resource
class_name Events_Res

# 触发方式
enum TriggerType {
	## 无
	None无,
	## 可交互的
	Interact交互,
	## 接触触发
	Touch触碰,
	## 自动触发
	Auto自动触发
}

## 事件名称
@export var title:String = ""

## 是否为障碍物,表示该事件是否可穿透
@export var is_collsion:bool = false

## 触发方式
@export var trigger_type:TriggerType = TriggerType.None无 

## 触发条件:表示该脚本只执行1次
@export var one_shot:bool = false

## 请在可视化编辑器操作
@export var tree:BaseEventNode ## 
@export var map:Dictionary  ## 字典

func _init(tree:BaseEventNode = null) -> void:
	self.tree = tree

## 查看语句数量，未完善
func size():
	var count:int = 1
	var node = self.tree
	print("node:",node)
	if !node: return 0
	while(true):
		node = node.next() ## 获得下一个
		if node:count+=1
		else: break
	return count
	pass
	
	
