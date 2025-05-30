extends Resource
class_name EventCondition

enum EventConditionType{
	Item
}

## 事件条件类型
@export var type:EventConditionType = EventConditionType.Item

var game:GamePlay:
	get(): return GameManager

# 该函数可在子类中重写
## 获得该条件的结果
func _get_result() -> bool:
	return true
